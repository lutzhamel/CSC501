% preamble.pl
% version 3.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% standard preamble for semantic definitions and proofs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure our unification algorithm is sound
:- set_prolog_flag(occurs_check,true). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define a predicate that allows us to write proof scores
% that make sense when we read them and also produce sensible
% output when running them.  this predicate allows us to
% write comment lines that will also print when the proof score
% is executed:
% :- >>> 'this will print to the terminal...'.

:- op(1000,fy,>>>).
>>> T :- write('>>> '), writeln(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the predicate '(+Syntax,+State) -->> -SemanticValue' computes
% the semantic value for each syntactic structure

:- op(700,xfx,-->>).
:- dynamic (-->>)/2.                % modifiable predicate
:- multifile (-->>)/2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the definition of the 'xis' predicate

:- ['xis.pl'].

