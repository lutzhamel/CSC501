% preamble.pl
% version 3.2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% standard preamble for semantic definitions and proofs
% (C) 2015 - Lutz Hamel, University of Rhode Island

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure our unification algorithm is sound
:- set_prolog_flag(occurs_check,true).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure our resolution algorithm is sound - negation of non-ground
% atom can lead to unsound refutations.  Therefore we should never
% negate a goal that is not ground.  Always use 'neg' instead of
% 'not' or '\+' to insure soundness.
%
% The predicate 'neg(+Goal)' checks whether the Goal is ground,
% if it is then it negates it otherwise it will throw an exception.

not(G) :- ground(G),!,\+(G).

not(_) :- throw('literal is not ground').


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% int as a short hand for integer
int(X) :- integer(X).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define a predicate that allows us to write proof scores
% that make sense when we read them and also produce sensible
% output when running them.  this predicate allows us to
% write comment lines that will also print when the proof score
% is executed:
% :- >>> 'this will print to the terminal...'.

:- op(1150,fy,>>>).
>>> T :- write('>>> '), writeln(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following predicates constiture our proofscore meta-language

:- op(1150,fy,assume).
assume E :- 
	write('    Assuming: '),
	writeln(E),
	asserta(E).

:- op(1150,fy,remove).
remove E :- 
	write('    Removing: '),
	writeln(E),
	retract(E).

:- op(1150,fy,show).
show G :- 
	write('    Showing: '),
	writeln(G),
	call(G),!.

% we let the following be successful so that we don't get an
% error message from the Prolog engine.
show _ :- nl,writeln('    !!!Show Goal failed!!!'),nl. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a predicate that allows us to assume programs in the proof score
% in a much more readable fashion

:- op(950,fy,program).
:- dynamic (program)/1.                % modifiable predicate
:- multifile (program)/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the structure +State :: +Syntax ==> -SemanticValue is interpreted
% as: the Syntax maps to the SemanticValue under the assumptioin of
% State.

:- op(750,xfx,==>).
:- dynamic (==>)/2.                % modifiable predicate
:- multifile (==>)/2.

:- op(750,xfx,>-->).
:- dynamic (>-->)/2.                % modifiable predicate
:- multifile (>-->)/2.

:- op(800,xfx,::).
:- dynamic (::)/2.                % modifiable predicate
:- multifile (::)/2.

% the following op is a tag for type rules.

:- op(950,fy,type).
:- dynamic (type)/1.                % modifiable predicate
:- multifile (type)/1.

% this rule examines the rule base to see if there are rules
% that do not need explicit state info.
_:: Syntax ==> Value :- Syntax ==> Value.

% this rule examines the type rule base to see if there are type rules
% that do not need explicit state info.
type _:: Syntax ==> Value :- type Syntax ==> Value.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the definition of the 'xis' predicate

:- consult('xis.pl').

