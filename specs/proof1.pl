% load preamble
:- ['preamble.pl'].

% proof1.pl
% Proof score:
%
:- >>> 'Show that'.
:- >>> '(forall x)(forall s)(forall vx)(exists V)[(add(x,mult(3,5)),s)-->>V ^ =(V,vx+15)]'.
:- >>> ' assuming lookup(x,s,vx)'.

% load semantics
:- ['sem.pl'].

% state our assumption
:- asserta(lookup(x,s,vx)).

% run the proof
:- (add(x,mult(3,5)),s)-->>V, V = vx + 15.

