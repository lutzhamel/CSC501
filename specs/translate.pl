% translate.pl
% version 1.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the definitions of the source and target languages
:- ['source.pl'].
:- ['target.pl'].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% predicate 'translate(+Source,-Target)' assigns semantics to the
% syntactic source language constructs using snippets of target language
% syntax.
:- dynamic translate/2.

translate(C,Target) :-
    int(C),
    Target = [push(C)],!.

translate(true,Target) :-
    Target = [push(true)],!.

translate(false,Target) :-
    Target = [push(false)],!.

translate(add(A,B),Target) :-
    translate(A,T1),
    translate(B,T2),
    T3 = [add],
    flatten([T1,T2,T3],Target),!.

translate(sub(A,B),Target) :-
    translate(A,T1),
    translate(B,T2),
    T3 = [sub],
    flatten([T1,T2,T3],Target),!.

translate(mult(A,B),Target) :-
    translate(A,T1),
    translate(B,T2),
    T3 = [mult],
    flatten([T1,T2,T3],Target),!.

translate(and(A,B),Target) :-
    translate(A,T1),
    translate(B,T2),
    T3 = [and],
    flatten([T1,T2,T3],Target),!.

translate(or(A,B),Target) :-
    translate(A,T1),
    translate(B,T2),
    T3 = [or],
    flatten([T1,T2,T3],Target),!.

translate(not(A),Target) :-
    translate(A,T1),
    T2 = [neg],
    flatten([T1,T2],Target),!.

translate(eq(A,B),Target) :-
    translate(A,T1),
    translate(B,T2),
    T3 = [eq],
    flatten([T1,T2,T3],Target),!.

translate(le(A,B),Target) :-
    translate(A,T1),
    translate(B,T2),
    T3 = [le],
    flatten([T1,T2,T3],Target),!.

translate(skip,[]) :- !.

translate(seq(C1,C2),Target) :-
    translate(C1,T1),
    translate(C2,T2),
    flatten([T1,T2],Target),!.

translate(assign(X,A),Target) :-
    translate(A,T1),
    T2 = [pop(X)],
    flatten([T1,T2],Target),!.

translate(if(B,C0,C1),Target) :-
    translate(B,T1),
    T2 = [jmpf(iflabel1)],
    translate(C0,T3),
    T4 = [jmp(iflabel2),label(iflabel1)],
    translate(C1,T5),
    T6 = [label(iflabel2)],
    flatten([T1,T2,T3,T4,T5,T6],Target),!.

translate(whiledo(B,C),Target) :-
    T1 = [label(whilelabel1)],
    translate(B,T2),
    T3 = [jmpf(whilelabel2)],
    translate(C,T4),
    T5 = [jmp(whilelabel1),label(whilelabel2)],
    flatten([T1,T2,T3,T4,T5],Target),!.

translate(X,Target) :-
    atom(X),
    Target = [push(X)],!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'ppc(+Code)'
% pretty print the code to the screen

ppc([]).

ppc([label(L)|R]) :- 
    write(label(L)),
    nl,
    ppc(R).

ppc([A|R]) :- 
    write('    '),
    write(A),
    nl,
    ppc(R).
