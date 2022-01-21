% proof-comm.pl
:- ['preamble.pl'].

:- >>> 'prove that add(a0,a1) ~ add(a1,a0)'.

% show that
% (forall s,a0,a1)(exists V0,V1)
%         [(add(a0,a1),s)-->>V0 ^ (add(a1,a0),s)-->>V1 ^ =(V0,V1)]
% assuming
% (a0,s) -->> va0.
% (a1,s) -->> va1.

% load semantics
:- ['sem.pl'].

% assumptions on semantic values of expressions
:- asserta((a0,s)-->>va0).
:- asserta((a1,s)-->>va1).

% assumption on integer addition commutativity
:- asserta(comm(A + B, B + A)).

% proof
:- (add(a0,a1),s) -->> V0, (add(a1,a0),s) -->> V1,comm(V0,V1).

