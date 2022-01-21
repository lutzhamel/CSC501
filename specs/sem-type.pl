% Version 2.0
% this version extended for typed declarations marked by %decl%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% complete semantics of the language IMP.
%
%  A ::= v  %decl%
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
%  T ::= int | real  %decl%
%
%  C ::= skip
%     | var(x,T)  %decl%
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

(C,_) -->> FVal :-                  % int constants %decl%
    int(C),
    FVal xis float(C),!.              % promote from int to real

(C,_) -->> C :-                     % real constants %decl%
    real(C),!.

(X,State) -->> FVal :-              % int variables %decl%
    atom(X),
    lookup(X,int,State,IVal),
    FVal xis float(IVal),!.

(X,State) -->> FVal :-              % real variables %decl%
    atom(X),
    lookup(X,real,State,FVal),!.

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

(skip,State) -->> State :- !.               % skip

(var(X,int),State) -->> _ :-     	    % var %decl%
    lookup(X,_,State,_),!,    
     fail.

(var(X,int),State) -->> OState :-	% var %decl%
    put(X,int,0,State,OState),!.  

(var(X,real),State) -->> _ :- 	  	% var %decl%
    lookup(X,_,State,_),!,    
    fail.

(var(X,real),State) -->> OState :-	% var %decl%
    put(X,real,0.0,State,OState),!.  

(assign(X,A),State) -->> OState :-      % assignment to real var  %decl%
    lookup(X,real,State,_),
    (A,State) -->> ValA,               
    FValA xis float(ValA),
    put(X,real,FValA,State,OState),!.

(assign(X,A),State) -->> OState :-     % assignment to int var  %decl%
    lookup(X,int,State,_),          
    (A,State) -->> ValA,              
    IValA xis truncate(ValA),
    put(X,int,IValA,State,OState),!.

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
% the predicate 'lookup(+Variable,+Type,+State,-Value)' looks up
% the variable in the state and returns its bound value.
:- dynamic lookup/4.                % modifiable predicate

lookup(_,_,s0,_) :- fail. %decl%

lookup(X,T,state([],S),Val) :-
    lookup(X,T,S,Val).

lookup(X,T,state([bind(Val,T,X)|_],_),Val).

lookup(X,T,state([_|Rest],S),Val) :- 
    lookup(X,T,state(Rest,S),Val).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'put(+Variable,+Type,+Value,+State,-FinalState)' adds
% a binding term to the state.
:- dynamic put/5.                   % modifiable predicate

put(X,T,Val,state(L,S),state([bind(Val,T,X)|L],S)).

put(X,T,Val,S,state([bind(Val,T,X)],S)) :- 
    atom(S).

