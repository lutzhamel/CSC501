% proof-loop.pl

:- ['preamble.pl'].

:- >>> 'prove that the value of y is equal to 6 when'.
:- >>> 'the following program p:'.
:- >>> '       assign(x,3) seq'.
:- >>> '       assign(y,1) seq'.
:- >>> '       whiledo(le(2,x),'.
:- >>> '               assign(y,mult(y,x)) seq'.
:- >>> '               assign(x,sub(x,1))'.
:- >>> '       )'.
:- >>> 'is run in the context of any state'.

% We need to prove
%           (forall s)(exists SF)[(p,s)-->>SF ^ lookup(y,SF,6)]

% proof
:- ['sem.pl'].

% A nice coding trick for long proofs:
%   'program' is a predicate that holds our program
program(assign(x,3) seq
        assign(y,1) seq
        whiledo(le(2,x), 
            assign(y,mult(y,x)) seq  
            assign(x,sub(x,1)))).

:- program(P),(P,s)-->>SF,lookup(y,SF,6).
