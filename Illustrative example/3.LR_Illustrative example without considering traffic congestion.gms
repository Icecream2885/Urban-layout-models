$title urban layout probelm with lagrangian relaxation algorithm
OPTIONS  ITERLIM=100000, RESLIM = 1000000, SYSOUT = OFF, SOLPRINT = OFF,  OPTCR= 0.01;

sets
i node /101,102,201,202,301,302,401,402,1001,2001/
m node types /home,office,other/
u attribute types /building,location,transport/
hb(i) home building /101,102/
hl(i) home location /201,202/
ol(i) office location /301,302/
ob(i) office building /401,402/
o(i) origin of super network /1001/
d(i) destination of super network /2001/;

alias (i,j);
alias (u,v);

parameter node_type(m,u,i)/
home.building.101      1
home.building.102      1
home.location.201      1
home.location.202      1
office.location.301    1
office.location.302    1
office.building.401    1
office.building.402    1
/;

parameter demand(i) /
1001  5
2001  5
/;

parameter origin_node(i) /
1001   1
/;

parameter destination_node(i) /
2001   1
/;

parameter fft(i,j)/
201.301  2
201.302  4
202.301  2
202.302  3
/;

parameter capacity(i,j)/
1001.101 5
1001.102 5
101.201  2
101.202  2
102.201  3
102.202  3
201.301  2
201.302  2
202.301  2
202.302  2
301.401  2
302.401  2
301.402  3
302.402  3
401.2001 5
402.2001 5
/;

parameter intermediate_node(i);
intermediate_node(i)=(1-origin_node(i))*(1-destination_node(i));

parameter pie(i,j);
pie(i,j)=0;

positive variable x(i,j) traffic flow between node i and node j;
positive variable x_lb(i,j);
binary variable y(i,j) wether there is an arc betwwen node i and j or not;
binary variable y_lb(i,j);
positive variable lamda(i,j) multipliers;
variable z,z_x,z_y  cost;

y.fx('1001','101')=1;
y.fx('1001','102')=1;
y.fx('201','301')=1;
y.fx('201','302')=1;
y.fx('202','301')=1;
y.fx('202','302')=1;
y.fx('401','2001')=1;
y.fx('402','2001')=1;

y_lb.fx('1001','101')=1;
y_lb.fx('1001','102')=1;
y_lb.fx('201','301')=1;
y_lb.fx('201','302')=1;
y_lb.fx('202','301')=1;
y_lb.fx('202','302')=1;
y_lb.fx('401','2001')=1;
y_lb.fx('402','2001')=1;


equations
cost
obj_flow
obj_assign
flow_on_node_origin(i)
flow_on_node_intermediate(i)
flow_on_node_destination(i)
lb_flow_on_node_origin(i)
lb_flow_on_node_intermediate(i)
lb_flow_on_node_destination(i)
arc_capacity(i,j)
*assign1(m,u,j)
*assign2(m,u,i)
assign_hb(i)
assign_hl(j)
assign_ob(j)
assign_ol(i)
lb_assign_hb(i)
lb_assign_hl(j)
lb_assign_ob(j)
lb_assign_ol(i)
;

cost..  z=e=sum((i,j),x(i,j)*fft(i,j));
obj_flow..   z_x=e=sum((i,j),x_lb(i,j)*(fft(i,j)+pie(i,j)));
obj_assign..  z_y=e=-sum((i,j),pie(i,j)*capacity(i,j)*y_lb(i,j));
flow_on_node_origin(i)$(origin_node(i)).. sum((j)$(capacity(i,j)>0.1), x(i,j)) =e= demand(i);
flow_on_node_destination(i)$(destination_node(i))..  sum((j)$(capacity(j,i)>0.1), x(j,i))=e= demand(i);
flow_on_node_intermediate(i)$(intermediate_node(i)).. sum((j)$(capacity(i,j)>0.1), x(i,j))-sum((j)$(capacity(j,i)>0.1),x(j,i))=e= 0;
arc_capacity(i,j)$(capacity(i,j)>0)..    x(i,j)=l=capacity(i,j)*y(i,j);
*assign1(m,u,j)$(node_type(m,'building',j))..  sum((i)$(node_type(m,'location',i)),y(i,j))=e=1;
*assign2(m,u,i)$(node_type(m,'location',i))..  sum((j)$(node_type(m,'building',j)),y(i,j))=e=1;
assign_hb(i)$(hb(i))..  sum(j$(hl(j)),y(i,j))=e=1;
assign_hl(j)$(hl(j))..  sum(i$(hb(i)),y(i,j))=e=1;
assign_ob(j)$(ob(j))..  sum(i$(ol(i)),y(i,j))=e=1;
assign_ol(i)$(ol(i))..  sum(j$(ob(j)),y(i,j))=e=1;
*flow balace of subproblem1
lb_flow_on_node_origin(i)$(origin_node(i)).. sum((j)$(capacity(i,j)>0.1), x_lb(i,j)) =e= demand(i);
lb_flow_on_node_destination(i)$(destination_node(i))..  sum((j)$(capacity(j,i)>0.1), x_lb(j,i))=e= demand(i);
lb_flow_on_node_intermediate(i)$(intermediate_node(i)).. sum((j)$(capacity(i,j)>0.1), x_lb(i,j))-sum((j)$(capacity(j,i)>0.1),x_lb(j,i))=e= 0;
*assignment constraints of subproblem2
lb_assign_hb(i)$(hb(i))..  sum(j$(hl(j)),y_lb(i,j))=e=1;
lb_assign_hl(j)$(hl(j))..  sum(i$(hb(i)),y_lb(i,j))=e=1;
lb_assign_ob(j)$(ob(j))..  sum(i$(ol(i)),y_lb(i,j))=e=1;
lb_assign_ol(i)$(ol(i))..  sum(j$(ob(j)),y_lb(i,j))=e=1;

model urban_layout /cost,flow_on_node_origin,flow_on_node_intermediate,flow_on_node_destination,arc_capacity,assign_hb,assign_hl,assign_ob,assign_ol/;
solve urban_layout using mip minimizing z;
display x.l, y.l, z.l;

File optimal_solution1/optimal_solution2.dat/;
Put optimal_solution1;
put @1,'i',@6,'j',@17,'x.l(i,j)'/
loop((i,j)$(x.l(i,j)), put @1, i.tl, @6, j.tl, @11, x.l(i,j)/);
loop((i,j)$(y.l(i,j)), put @1, i.tl, @6, j.tl, @11, y.l(i,j)/);
put @1, 'z.l',@5, z.l ;

model subproblem1 /obj_flow,lb_flow_on_node_origin,lb_flow_on_node_intermediate,lb_flow_on_node_destination/;
model subproblem2 /obj_assign,lb_assign_hb,lb_assign_hl,lb_assign_ob,lb_assign_ol/;

parameter z_lb;

parameter step;
step = 1;

parameter n_value;
n_value = 0;

parameter n;
n= 0;

parameter zlbest;
zlbest=0;

parameter subgradient_pie(i,j);
subgradient_pie(i,j)=0;



sets iter  subgradient iteration index / iter1 * iter30/;

File output_lb/result_LR2.txt/;
put output_lb;
put @10,'n',@27,'z_x.l',@47,'z_y.l',@67,'z_lb',@87,'zlbest' /

Loop (iter,
         solve subproblem1 using LP minimizing z_x;
         solve subproblem2 using MIP minimizing z_y;
         subgradient_pie(i,j)= x_lb.l(i,j)-capacity(i,j)*y_lb.l(i,j);
         pie(i,j)=max(0,pie(i,j)+step*subgradient_pie(i,j));
         n_value =n_value +1;
*         if(zlbest>10,
*            step=0.75**12
*            );
         step= 0.75*step;
         n=n_value-1;
         z_lb = z_x.l + z_y.l;
         zlbest = max(zlbest,z_lb);


         display z_x.l;
         display z_y.l;
         display x_lb.l;
         display y_lb.l;
         display subgradient_pie;
         display step;
         display pie;
         display z_lb;
         display zlbest;
         put @1,n,@20,z_x.l,@40,z_y.l,@60,z_lb,@80,zlbest /

);
