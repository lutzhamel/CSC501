% max-prepost.pl
:-['sem.pl'].

:- >>> 'show that program P="if(le(n,m),assign(z,m),assign(z,n))"'.
:- >>> 'satisfies the program specification:'.
:- >>> ' pre(S) = lookup(m,S,vm) ^ lookup(n,S,vm)'.
:- >>> ' post(Q) = lookup(z,Q,VZ)) ^ V xis max(vm,vn) ^ VZ = V'.

program(if(le(n,m),assign(z,m),assign(z,n))).

:- >>> 'assert precondition'.
:- asserta(lookup(m,s,vm)).
:- asserta(lookup(n,s,vn)).                                                                        
                                                                                                   
:- >>> 'show that postcondition holds; case analysis on values vm and vn'.                                                       
:- >>> 'case max(vm,vn)=vm'.                                                                       
:- asserta(vm xis max(vm,vn)).
% this implies that
:- asserta(true xis (vn =< vm)).
:- program(P),  (P,s) -->> Q, lookup(z,Q,VZ), V xis max(vm,vn), VZ = V.
:- retract(vm xis max(vm,vn)).
:- retract(true xis (vn =< vm)).

:- >>> 'case max(vm,vn)=vn'.
:- asserta(vn xis max(vm,vn)).
% this implies that
:- asserta(false xis (vn =< vm)).
:- program(P), (P,s) -->> Q, lookup(z,Q,VZ), V xis max(vm,vn), VZ = V.
:- retract(vn xis max(vm,vn)).
:- retract(false xis (vn =< vm)).
