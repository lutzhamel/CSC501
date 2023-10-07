% xis.pl
% version 4.1
% (C) 2015 - Lutz Hamel, University of Rhode Island
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'xis(-TermOrValue,+term)' takes a term and
% tries to evaluate it to an int, float, or boolean value.  if it succeeds then
% TermOrValue will be unified with a value otherwise
% it will unified with a term structure representing the value.
% you can think of the 'xis' predicate as a special version of the 'is'
% predicate that allows indeterminants in its term structure.
% therefore the name 'xis' - eXtended IS.

:- dynamic 'xis'/2.
:- multifile 'xis'/2.
:- op(750,xfx,xis).  % infix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'xis' for boolean expressions not supported by 'is'
% we want to be able to have boolean expressions in our term trees

:- op(1000,fy,not).                  % not operator
:- op(1000,yfx,and).                 % conjunction operator
:- op(1000,yfx,or).                  % disjunction operator


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'xis' as an extension of 'is' but it support indeterminants and logical expressions

A xis B :-                  % if B is 'is' evaluable, compute the value with 'is'
	is_evaluable(B),
	A is B,!.

A xis B :-                  % if B is boolean evaluable, compute the value with bool_eval.
	bool_evaluable(B),
	bool_eval(B,A),!.

A xis A :-                  % in this case atoms are structures that cannot be evaluated
	atom(A),!.

A xis B :-                  % recurse through the structure and eval as much as possible
	functor(B,Name,Arity),
	xis_evalchild(Arity,B,[],Result),
	A =.. [Name|Result],!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'is_evaluable(+Term)' returns true for terms that can
% be evaluated with the builtin 'is' predicate, otherwise false.

is_evaluable(F) :-
	is_num(F), !.

is_evaluable(F) :-
        current_arithmetic_function(F),
        forall(arg(_,F,A), is_evaluable(A)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'bool_evaluable(+Term)' returns true for terms that can
% be evaluated with the 'bool_eval' predicate, otherwise false.

bool_evaluable(F) :-
	is_bool(F), !.

bool_evaluable(F) :-
        current_bool_op(F),
        forall(arg(_,F,A), bool_evaluable(A)).

bool_evaluable(F) :-
        current_relational_op(F),
        forall(arg(_,F,A), is_evaluable(A)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'current_relational_op(+Term)' returns true
% if the toplevel operator in Term is a relational operator.

current_relational_op(A) :-
	functor(A,Name,_),
	member(Name,[(==),(<),(=<),(>),(>=)]).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'current_bool_op(+Term)' returns true
% if the toplevel operator in Term is a boolean operator.

current_bool_op(A) :-
	functor(A,Name,_),
	member(Name,[(and),(or),(not),(~)]).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'xis_evalchild(+ChildIndex,+ParentNode,+InputList,-OutputList)'
% prepends the value of a child at child index evaluated with 'xis'
% to the InputList and returns it in OutputList.  The procedure
% is called recursively until all children from arity a to 1 have been
% processed.

xis_evalchild(1,B,Input,Output) :-
	arg(1,B,Child),
	VChild xis Child,
	Output = [VChild|Input],!.

xis_evalchild(I,B,Input,Output) :-
	arg(I,B,Child),
	VChild xis Child,
	T = [VChild|Input],
	Next is I - 1,
	xis_evalchild(Next,B,T,Output),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'bool_eval(+Input,-Ouput) computes the boolean value
% of a term into Output bottom up.

% constant
bool_eval(Input,Input) :-
	is_bool(Input),!.

% not
bool_eval(not A,true) :-
	bool_eval(A,false),!.

bool_eval(not A,false) :-
	bool_eval(A,true),!.

% and
bool_eval(A and B,true) :-
	bool_eval(A,true),
	bool_eval(B,true),!.
	
bool_eval(A and B,false) :-
	bool_eval(A,true),
	bool_eval(B,false),!.

bool_eval(A and B,false) :-
	bool_eval(A,false),
	bool_eval(B,true),!.
	
bool_eval(A and B,false) :-
	bool_eval(A,false),
	bool_eval(B,false),!.
	
% or
bool_eval(A or B,false) :-
	bool_eval(A,false),
	bool_eval(B,false),!.
	
bool_eval(A or B,true) :-
	bool_eval(A,true),
	bool_eval(B,false),!.

bool_eval(A or B,true) :-
	bool_eval(A,false),
	bool_eval(B,true),!.
	
bool_eval(A or B,true) :-
	bool_eval(A,true),
	bool_eval(B,true),!.
	
% relational expressions are different because they have numeric arguments
bool_eval(T,true) :- 
	current_relational_op(T),
	xis_evalchild(2,T,[],Result),
	[V1,V2] = Result,
	is_num(V1),
	is_num(V2),
	functor(T,Name,_),
	A =.. [Name|Result],
	call(A),!.

bool_eval(T,false) :- 
	current_relational_op(T),
	xis_evalchild(2,T,[],Result),
	[V1,V2] = Result,
	is_num(V1),
	is_num(V2),
	functor(T,Name,_),
	A =.. [Name|Result],
	not call(A),!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following predicates are here to make the property testing 
% dynamic for proof purposes -- the builtins are not dynamic,
% ie. cannot be extended by the user.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'is_bool(+term)' takes a term and returns true
% if term is either atom 'true' or 'false'

:- dynamic is_bool/1.
is_bool(true).
is_bool(false).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'is_int(+term)' takes a term and returns true
% if term is an int value

:- dynamic is_int/1.
is_int(T) :- integer(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'is_num(+term)' takes a term and returns true
% if term is a value

:- dynamic is_num/1.
is_num(T) :- number(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'is_real(+term)' takes a term and returns true
% if term is a floating point value

:- dynamic is_real/1.
is_real(T) :- float(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate 'is_var(+term)' takes a term and returns true
% if term looks like a variable name

:- dynamic is_var/1.
is_var(X) :- atom(X).
