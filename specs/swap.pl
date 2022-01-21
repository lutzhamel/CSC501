% swap.pl
:-['sem.pl'].

:- >>> 'show that program P="assign(t,x) seq assign(x,y) seq assign(y,t))"'.
:- >>> 'satisfies the program specification:'.
:- >>> ' (P,s)-->>Q,lookup(y,s,VY),lookup(x,Q,VY),lookup(x,s,VX),lookup(y,Q,VX)'.

program(assign(t,x) seq assign(x,y) seq assign(y,t)).                                              
                                                                                                   
:- asserta(lookup(x,s,vx)).
:- asserta(lookup(y,s,vy)).                                                                        
                                                                                                   
:- program(P),
     (P,s) -->> Q,
     lookup(y,s,VY),
     lookup(x,Q,VY),
     lookup(x,s,VX),                                                                               
     lookup(y,Q,VX).
