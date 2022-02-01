% proof-equiv-bool.pl

:- ['preamble.pl'].

:- >>> 'prove that true ~ not(false)'.
%
% show that
% (forall s)(exists B0,B1)
%         [(true,s)-->>B0 ^ (not(false)s)-->>B1 ^ =(B0,B1)]

% load semantics
:- ['sem.pl'].

% proof
:- (true,s)-->>B0,(not(false),s)-->>B1,B0=B1.

