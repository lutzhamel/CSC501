% sem-block.pl
% Version 2.0
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
%     |  put(A)		%io%
%     |  get(x)		%io%
%     |  block(C)	%block%
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

% Note the difference to our previous notion
% of variable declaration -- here we allow
% redeclaration at any time
(var(X),State) -->> OState :-          % decl
    declarevar(X,State,OState),!.           

(assign(X,A),State) -->> OState :-     % assignment
    lookup(X,State,_),                 % only allowed to assign to variables
    (A,State) -->> ValA,               % that have been declared
    bindval(X,ValA,State,OState),!.

(put(A),State) -->> State :-           %io%  writing
    (A,State) -->> ValA,
    write(A),
    write(' is '),
    writeln(ValA),!.  

(get(X),State) -->> OState :-          %io% reading
    lookup(X,State,_),
    write('Enter integer value for '),
    write(X),
    write(': '),
    read(Val),
    int(Val),
    bindval(X,Val,State,OState),!.

(block(C),State) -->> OState :-        %block%     block statement
    pushenv(State,LocalState),
    (C,LocalState) -->> S,
    popenv(S,OState),!.

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

%block%

lookup(_,s0,_) :- fail.

lookup(X,env([],S),Val) :-
    lookup(X,S,Val),!.

lookup(X,env([bind(Val,X)|_],_),Val).

lookup(X,env([_|Rest],S),Val) :- 
    lookup(X,env(Rest,S),Val),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'bindval(+Variable,+Value,+State,-FinalState)' updates
% a binding term in the state.  this update is done "in place"
% in order to support global variables.  the predicate has to
% search both the binding list and the stack of binding
% lists.
:- dynamic bindval/4.                   % modifiable predicate

%block%

bindval(_,_,s0,_) :- 
    fail.

bindval(X,Val,S,env([bind(Val,X)],S)) :-
    atom(S),!.

bindval(X,Val,env([],S),env([],NewS)) :-
    bindval(X,Val,S,NewS),!.

bindval(X,Val,env([bind(_,X)|L],S),env([bind(Val,X)|L],S)).

bindval(X,Val,env([bind(V,Y)|L],S),env([bind(V,Y)|NewL],NewS)) :-
    bindval(X,Val,env(L,S),env(NewL,NewS)),!.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'declarevar(+Variable,+State,-FinalState)' declares
% a variable by inserting a new binding term into the current
% environment.
:- dynamic declarevar/3.                   % modifiable predicate

%block%

declarevar(X,S,env([bind(0,X)],S)) :-
    atom(S),!.

declarevar(X,env(L,S),env([bind(0,X)|L],S)) :- !.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'pushenv(+State,-FinalState)' pushes
% a new binding term list on the stack
:- dynamic pushenv/2.

%block%

pushenv(S,env([],S)) :- !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'popenv(+State,-FinalState)' pops
% a  binding term list off the stack
:- dynamic popenv/2.

%block%

popenv(env(_,S),S) :- !.



