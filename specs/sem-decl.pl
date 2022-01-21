% sem-decl.pl
% Version 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% complete semantics of the source language:
%
%  A ::= n
%     |  x
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
%     |  var(x)       %decl%
%     |  assign(x,A)
%     |  seq(C,C)
%     |  if(B,C,C)
%     |  whiledo(B,C)
%
% for convenience sake make seq infix and left associative
:- op(1200,yfx,seq).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load definitions we need for proofs and the semantics
:- ['preamble.pl'].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we need the definition of predicate 'xis' for the 
% evaluation of our terms.
:- ['xis.pl'].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of arithmetic expressions

(C,_) -->> C :-                    % constants
    int(C),!.

(X,State) -->> Val :-              % variables
    atom(X),
    lookup(X,State,Val),!.

(add(A,B),State) -->> Val :-       % addition
    (A,State) -->> ValA,
    (B,State) -->> ValB,
    Val xis ValA + ValB,!.

(sub(A,B),State) -->> Val :-       % subtraction
    (A,State) -->> ValA,
    (B,State) -->> ValB,
    Val xis ValA - ValB,!.

(mult(A,B),State) -->> Val :-     % multiplication
    (A,State) -->> ValA,
    (B,State) -->> ValB,
    Val xis ValA * ValB,!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of boolean expressions

% Note: we introduce new terms for the Prolog conjunction and 
% disjunction.  We could have used the built-in ',' and ';'
% operators but this would make terms difficult to read.

(true,_) -->> true :- !.               % constants

(false,_) -->> false :- !.             % constants

(eq(A,B),State) -->> Val :-            % equality
    (A,State) -->> ValA,         
    (B,State) -->> ValB,         
    Val xis (ValA =:= ValB),!. 
    
(le(A,B),State) -->> Val :-            % le
    (A,State) -->> ValA,
    (B,State) -->> ValB,
    Val xis (ValA =< ValB),!.
    
(not(A),State) -->> Val :-             % not
    (A,State) -->> ValA,
    Val xis (not ValA),!.

(and(A,B),State) -->> Val :-           % and
    (A,State) -->> ValA,
    (B,State) -->> ValB,
    Val xis (ValA and ValB),!.

(or(A,B),State) -->> Val :-            % or
    (A,State) -->> ValA,
    (B,State) -->> ValB,
    Val xis (ValA or ValB),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of commands

(skip,State) -->> State :- !.          % skip

%decl%
(var(X),State) -->> _ :-               % decl, if lookup is successful
    lookup(X,State,_),!,               % then var(x) must fail, only
    fail.                              % one var declaration allowed

%decl%
(var(X),State) -->> OState :-          % decl, we have shown that lookup is not 
    put(X,0,State,OState),!.           % successful, therefore enter the new var

%decl%
(assign(X,A),State) -->> OState :-     % assignment
    lookup(X,State,_),                 % only allowed to assign to variables
    (A,State) -->> ValA,               % that have been declared
    put(X,ValA,State,OState),!.

(seq(C0,C1),State) -->> OState :-      % composition, seq
    (C0,State) -->> S0,
    (C1,S0) -->> OState,!.

(if(B,C0,_),State) -->> OState :-     % if
    (B,State) -->> true,
    (C0,State) -->> OState,!.

(if(B,_,C1),State) -->> OState :-     % if
    (B,State) -->> false,
    (C1,State) -->> OState,!.

(whiledo(B,_),State) -->> OState :-    % while
    (B,State) -->> false,
    State=OState,!.

(whiledo(B,C),State) -->> OState :-    % while
    (B,State) -->> true,
    (C,State) -->> SC,
    (whiledo(B,C),SC) -->> OState,!. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'lookup(+Variable,+State,-Value)' looks up
% the variable in the state and returns its bound value.
:- dynamic lookup/3.                % modifiable predicate

%decl%
% if we get to this point then the variable
% was not declared, error.
lookup(_,s0,_) :- !,fail. 

lookup(X,state([],S),Val) :-
    lookup(X,S,Val).

lookup(X,state([bind(Val,X)|_],_),Val).

lookup(X,state([_|Rest],S),Val) :- 
    lookup(X,state(Rest,S),Val).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'put(+Variable,+Value,+State,-FinalState)' adds
% a binding term to the state.
:- dynamic put/4.                   % modifiable predicate

put(X,Val,state(L,S),state([bind(Val,X)|L],S)).

put(X,Val,S,state([bind(Val,X)],S)) :- 
    atom(S).


