% Version 2.3
% This specification implements a simple block structured language
% with variable declarations, I/O, and function calls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% complete semantics of the language IMP.
%
%  A ::= n
%     |  x
%     |  add(A,A)
%     |  sub(A,A)
%     |  mult(A,A)
%     |  call(f,[ PL ])  
%     |  call(f, [ ])
%
%  PL::= P , PL  
%     |  P
%
%  P ::= assign(x,A) 
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
%     |  var(x)       
%     |  assign(x,A)
%     |  fun(f,[ FL ],C,A)  
%     |  fun(f,[ ],C,A)
%     |  put(A)
%     |  get(x)
%     |  seq(C,C)
%     |  block(C)
%     |  if(B,C,C)
%     |  whiledo(B,C)
%
% FL ::= x , FL  
%     |  x
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
% the semantic value of an expression is a **pair**: (Value,NewState)

(C,State) -->> (C,State) :-                % constants
    int(C),!.

(X,State) -->> (Val,State) :-              % variables
    atom(X),
    lookup(X,State,Val),!.

(add(A,B),State) -->> (Val,OState) :-      % addition
     (A,State) -->> (ValA,S),
     (B,S) -->> (ValB,OState),
     Val xis (ValA + ValB),!.

(sub(A,B),State) -->> (Val,OState) :-      % subtraction
     (A,State) -->> (ValA,S),
     (B,S) -->> (ValB,OState),
     Val xis (ValA - ValB),!.

(mult(A,B),State) -->> (Val,OState) :-      % multiplication
     (A,State) -->> (ValA,S),
     (B,S) -->> (ValB,OState),
     Val xis (ValA * ValB),!.

(call(F,[ ]),State) -->> (Val,OState) :-   % function call
    lookup(F,State,funval([ ],C,A)),
    pushenv(State,LocalState),
    (C,LocalState) -->> S1,
    (A,S1) -->> (Val,S2),
    popenv(S2,OState),!.     

(call(F,PList),State) -->> (Val,OState) :- % function call
    %lookup(F,State,funval(FList,C,A)),
    lookup(F,State,funval(_,C,A)),
    pushenv(State,LocalState),
    % possible implementation for positional correspondence
    % declareparams(FList,PList,LocalState,S1), 
    declareparams(PList,LocalState,S1),
    (C,S1) -->> S2,
    (A,S2) -->> (Val,S3),
    popenv(S3,OState),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of boolean expressions
% the semantic value of a boolean expression is a **pair**: (Value,NewState)

% Note: we introduce new terms for the Prolog conjunction and 
% disjunction.  We could have used the built-in ',' and ';'
% operators but this would make terms difficult to read.
:- op(1000,yfx,and).                   % conjunction operator
:- op(1000,yfx,or).                   % disjunction operator
:- op(1000,fy,not).                    % not operator

(true,State) -->> (true,State) :- !.    % constants

(false,State) -->> (false,State) :- !.  % constants

(eq(A,B),State) -->> (Val,OState) :-    % equality
    (A,State) -->> (ValA,S),         
    (B,S) -->> (ValB,OState),         
    Val xis (ValA =:= ValB),!. 
    
(le(A,B),State) -->> (Val,OState) :-    % le
    (A,State) -->> (ValA,S),
    (B,S) -->> (ValB,OState),
    Val xis (ValA =< ValB),!.
    
(not(A),State) -->> (Val,OState) :-      % not
    (A,State) -->> (ValA,OState),
    Val xis (not ValA),!.

(and(A,B),State) -->> (Val,OState) :-     % and
    (A,State) -->> (ValA,S),
    (B,S) -->> (ValB,OState),
    Val xis (ValA and ValB),!.

(or(A,B),State) -->> (Val,OState) :-     % or
    (A,State) -->> (ValA,S),
    (B,S) -->> (ValB,OState),
    Val xis (ValA or ValB),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% semantics of commands
% the semantic value of a command is a state

(skip,State) -->> State :- !.          % skip

(var(X),State) -->> OState :-          % decl        
    declarevar(X,0,State,OState),!.           

(assign(X,A),State) -->> OState :-     % assignment
    lookup(X,State,_),
    (A,State) -->> (ValA,S),               
    bindval(X,ValA,S,OState),!.    

(put(A),State) -->> OState :-           % writing
    (A,State) -->> (ValA,OState),
    write(A),
    write(' is '),
    writeln(ValA),!.  

(get(X),State) -->> OState :-          % reading
    lookup(X,State,_),
    write('Enter integer value for '),
    write(X),
    write(': '),
    read(Val),
    int(Val),
    bindval(X,Val,State,OState),!.

(seq(C0,C1),State) -->> OState :-      % composition, seq
    (C0,State) -->> S0,
    (C1,S0) -->> OState,!.

(block(C),State) -->> OState :-        % block statement
    pushenv(State,LocalState),
    (C,LocalState) -->> S,
    popenv(S,OState),!.

(if(B,C0,C1),State) -->> OState :-     % if
    (B,State) -->> (ValB,S),
    (ValB=true -> ((C0,S) -->> OState);
                  ((C1,S) -->> OState)),!.

(whiledo(B,C),State) -->> OState :-    % while
    (B,State) -->> (ValB,S),
    (ValB=false -> S=OState ;
                   ((C,S) -->> SC,
                    (whiledo(B,C),SC) -->> OState)),!. 

(fun(F,L,C,A),State) -->> OState :-    % function declaration
    declarevar(F,funval(L,C,A),State,OState),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'lookup(+Variable,+State,-Value)' looks up
% the variable in the state and returns its bound value.
:- dynamic lookup/3.                % modifiable predicate

lookup(_,s0,_) :- fail.

lookup(X,env([],S),Val) :-
    lookup(X,S,Val).

lookup(X,env([bind(Val,X)|_],_),Val).

lookup(X,env([_|Rest],S),Val) :- 
    lookup(X,env(Rest,S),Val).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'bindval(+Variable,+Value,+State,-FinalState)' updates
% a binding term in the state.  this update is done "in place"
% in order to support global variables.  the predicate has to
% search both the binding list and the stack of binding
% lists.
:- dynamic bindval/4.                   % modifiable predicate

bindval(_,_,s0,_) :- 
    fail.

bindval(X,Val,env([],S),env([],NewS)) :-
    bindval(X,Val,S,NewS).

bindval(X,Val,env([bind(_,X)|L],S),env([bind(Val,X)|L],S)).

bindval(X,Val,env([bind(V,Y)|L],S),env([bind(V,Y)|NewL],NewS)) :-
    bindval(X,Val,env(L,S),env(NewL,NewS)).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'declarevar(+Variable,+Val,+State,-FinalState)' declares
% a variable by inserting a new binding term into the current
% environment.
:- dynamic declarevar/4.                   % modifiable predicate

declarevar(X,V,S,env([bind(V,X)],S)) :-
    atom(S),!.

declarevar(X,V,env(L,S),env([bind(V,X)|L],S)).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'declareparams(+ActualList,+State,-FinalState)' declares
% a non-empty list of formal variables by inserting new binding terms into 
% the current environment.
:- dynamic declareparams/3.                   % modifiable predicate

% Note: positional correspondence can easily be implemented by
% co-recusion onf the formal parameter list

declareparams([assign(X,A)],State,OState) :-
    (A,State) -->> (ValA,S1),               
    declarevar(X,ValA,S1,OState).

declareparams([assign(X,A)|TA],State,OState) :-
    (A,State) -->> (ValA,S1),               
    declarevar(X,ValA,S1,S2),
    declareparams(TA,S2,OState).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'pushenv(+State,-FinalState)' pushes
% a new binding term list on the stack
:- dynamic pushenv/2.

pushenv(S,env([],S)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'popenv(+State,-FinalState)' pops
% a  binding term list off the stack
:- dynamic popenv/2.

popenv(env(_,S),S).


