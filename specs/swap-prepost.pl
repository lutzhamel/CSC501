% swap-prepost.pl
:-['sem.pl'].

:- >>> 'show that program P="assign(t,x) seq assign(x,y) seq assign(y,t))"'.
:- >>> 'satisfies the program specification:'.
:- >>> ' pre(R) = lookup(x,R,vx) ^ lookup(y,R,vy)'.
:- >>> ' post(T) = lookup(x,T,vy) ^ lookup(y,T,vx)'.

program(assign(t,x) seq assign(x,y) seq assign(y,t)).                                              
                                                                                                   
:- >>> 'assert precondition'.                                                                      
:- asserta(lookup(x,s,vx)).
:- asserta(lookup(y,s,vy)).                                                                        
                                                                                                   
:- >>> 'show that postcondition holds'.                                                            
:- program(P),
     (P,s) -->> Q,
     lookup(x,Q,vy),
     lookup(y,Q,vx).                                                                               
