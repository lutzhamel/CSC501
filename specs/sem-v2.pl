% Version 2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% complete semantics of the language IMP.
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
%     |  assign(x,A)
%     |  seq(C,C)
%     |  if(B,C,C)
%     |  whiledo(B,C)
%
% for convenience sake make seq infix and left associative
:- op(1200,yfx,seq).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate '(+Syntax,+State) -->> -SemanticValue' computes
% the semantic value for each syntactic structure
:- op(700,xfx,-->>).
:- dynamic (-->>)/2.                % modifiable predicate

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
     valterm(ValA + ValB,Val),!.

(sub(A,B),State) -->> Val :-       % subtraction
     (A,State) -->> ValA,
     (B,State) -->> ValB,
     valterm(ValA - ValB,Val),!.

(mult(A,B),State) -->> Val :-     % multiplication
     (A,State) -->> ValA,
     (B,State) -->> ValB,
     valterm(ValA * ValB,Val),!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of boolean expressions

% Note: we introduce new terms for the Prolog conjunction and 
% disjunction.  We could have used the built-in ',' and ';'
% operators but this would make terms difficult to read.
:- op(1000,yfx,and).                   % conjunction operator
:- op(1000,yfx,or).                   % disjunction operator
:- op(1000,fy,not).                    % not operator

(true,_) -->> true :- !.               % constants

(false,_) -->> false :- !.             % constants

(eq(A,B),State) -->> Val :-            % equality
    (A,State) -->> ValA,         
    (B,State) -->> ValB,         
    valterm(ValA =:= ValB,Val),!. 
    
(le(A,B),State) -->> Val :-            % le
    (A,State) -->> ValA,
    (B,State) -->> ValB,
    valterm(ValA =< ValB,Val),!.
    
(not(A),State) -->> Val :-             % not
    (A,State) -->> ValA,
    valterm(not ValA,Val),!.

(and(A,B),State) -->> Val :-           % and
    (A,State) -->> ValA,
    (B,State) -->> ValB,
    valterm(ValA and ValB,Val),!.

(or(A,B),State) -->> Val :-            % or
    (A,State) -->> ValA,
    (B,State) -->> ValB,
    valterm(ValA or ValB,Val),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of commands

(skip,State) -->> State :- !.          % skip

(assign(X,A),State) -->> OState :-     % assignment
    (A,State) -->> ValA,
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

(whiledo(B,_),State) -->> State :-    % while
    (B,State) -->> false,!.


(whiledo(B,C),State) -->> OState :-    % while
    (B,State) -->> true,
    (C,State) -->> SC,
    (whiledo(B,C),SC) -->> OState,!. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'lookup(+Variable,+State,-Value)' looks up
% the variable in the state and returns its bound value.
:- dynamic lookup/3.                % modifiable predicate

lookup(_,s0,0).

lookup(X,state([],S),Val) :-
    lookup(X,S,Val).

lookup(X,state([bind(Val,X)|_],_),Val).

lookup(X,state([_|Rest],S),Val) :- 
    lookup(X,state(Rest,S),Val).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'put(+Variable,+Value,+State,-FinalState)' adds
% a binding term to the state.
:- dynamic put/4.                   % modifiable predicate

put(X,Val,S,state([bind(Val,X)],S)) :- 
    atom(S).

put(X,Val,state(L,S),state([bind(Val,X)|L],S)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'valterm(+term,-TermOrValue)' takes a term and
% tries to evaluate it to an int value.  if it succeeds then
% TermOrValue will be unified with an int value otherwise
% it will unified with a term structure representing an int value.
:- dynamic valterm/2.

valterm(A + B, V) :-                 % int addition
    int(A), 
    int(B), 
    V is A + B.

valterm(A - B, V) :-                 % int subtraction
    int(A), 
    int(B), 
    V is A - B.

valterm(A * B, V) :-                 % int multiplication
    int(A), 
    int(B), 
    V is A * B.

valterm(A =:= B, true) :-            % int equality, true
    int(A), 
    int(B), 
    A =:= B.

valterm(A =:= B, false) :-           % int equality, false
    int(A), 
    int(B), 
    not(A =:= B).

valterm(A =< B, true) :-            % int less than, true
    int(A), 
    int(B), 
    A =< B.

valterm(A =< B, false) :-           % int less than, false
    int(A), 
    int(B), 
    not(A =< B).

valterm(not true, false).        % not, false

valterm(not false, true).        % not, true

valterm(true and true, true).    % and, true

valterm(A and B, false) :-            % and, false
    bool(A),
    bool(B).

valterm(false or false, false). % or, false

valterm(A or B, true) :-             % or, true
    bool(A),
    bool(B).

valterm(T,T).                  % catch all, return the term structure
                                    % NOTE: has to be the last rule of the
                                    %       'valterm' definition

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'bool(+term)' takes a term and returns true
% if term is either atom 'true' or 'false'
:- dynamic bool/1.

bool(true).
bool(false).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'int(+term)' takes a term and returns true
% if term is an int value
:- dynamic int/1.

int(T) :- integer(T).

