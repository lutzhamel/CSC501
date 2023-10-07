% sem.pl
% Version 3.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of the IMP language:
%
%  A ::= n          -- any integer
%     |  x          -- any variable
%     |  add(A,A)
%     |  sub(A,A)
%     |  mult(A,A)
%
%  B ::= true
%     |  false
%     |  eq(A,A)
%     |  le(A,A)
%     |  not(B)
%     |  and(B,B)
%     |  or(B,B)
%
%  C ::= skip
%     |  assign(x,A)
%     |  seq(C,C)
%     |  if(B,C,C)
%     |  whiledo(B,C)
%
% for convenience sake make seq infix and left associative
:- op(1200,yfx,seq).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load our state representation
:- consult("state.pl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of arithmetic expressions

_:: C ==> C :-                    % constants
    int(C),!.

State:: X ==> Val :-              % variables
    atom(X),
    atom_length(X,1),             % we only allow single char vars
    State:: lookup(X) >--> Val,!.

State:: add(A,B)  ==> Val :-       % addition
    State:: A ==> ValA,
    State:: B ==> ValB,
    Val xis ValA + ValB,!.

State:: sub(A,B) ==> Val :-       % subtraction
    State:: A ==> ValA,
    State:: B ==> ValB,
    Val xis ValA - ValB,!.

State:: mult(A,B) ==> Val :-     % multiplication
    State:: A ==> ValA,
    State:: B ==> ValB,
    Val xis ValA * ValB,!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of boolean expressions

% Note: we introduce new terms for the Prolog conjunction and 
% disjunction.  We could have used the built-in ',' and ';'
% operators but this would make terms difficult to read.

_:: true ==> true :- !.               % constants

_:: false ==> false :- !.             % constants

State:: eq(A,B) ==> Val :-            % equality
    State:: A ==> ValA,         
    State:: B ==> ValB,         
    Val xis ValA == ValB,!. 
    
State:: le(A,B) ==> Val :-            % le
    State:: A ==> ValA,
    State:: B ==> ValB,
    Val xis ValA =< ValB,!.
    
State:: not(A) ==> Val :-             % not
    State:: A ==> ValA,
    Val xis (not ValA),!.             % NOTE: we need the parens here

State:: and(A,B) ==> Val :-           % and
    State:: A ==> ValA,
    State:: B ==> ValB,
    Val xis (ValA and ValB),!.

State:: or(A,B) ==> Val :-            % or
    State:: A ==> ValA,
    State:: B ==> ValB,
    Val xis (ValA or ValB),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of commands

State:: skip ==> State :- !.          % skip

State:: assign(X,A) ==> OState :-     % assignment
    State:: A ==> ValA,
    State:: put(X,ValA) >--> OState,!.

State:: seq(C0,C1) ==> OState :-      % composition, seq
    State:: C0 ==> S0,
    S0:: C1 ==> OState,!.

State:: if(B,C0,_) ==> OState :-     % if (true)
    State:: B ==> true,
    State:: C0 ==> OState,!.

State:: if(B,_,C1) ==> OState :-     % if (false)
    State:: B ==> false,
    State:: C1 ==> OState,!.

State:: whiledo(B,_) ==> State :-    % while (false)
    State:: B ==> false,!.

State:: whiledo(B,C) ==> OState :-    % while (true)
    State:: B ==> true,
    State:: C ==> SC,
    SC:: whiledo(B,C) ==> OState,!. 



