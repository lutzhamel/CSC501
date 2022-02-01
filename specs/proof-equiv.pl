% load preamble
:- ['preamble.pl'].

% proof-equiv.pl
:- >>> ' prove that mult(2,3) ~ add(3,3)'.
%
% show that
% (forall s)(exists V0,V1)
%         [(mult(2,3),s)-->>V0 ^ (add(3,3),s)-->>V1 ^ =(V0,V1)]

% load semantics
:- ['sem.pl'].

% proof
:- (mult(2,3),s)-->>V0 , (add(3,3),s)-->>V1 , V0 = V1.

