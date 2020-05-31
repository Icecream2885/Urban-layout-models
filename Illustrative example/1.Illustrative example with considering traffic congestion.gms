$title urban layout probelm
OPTIONS  ITERLIM=100000, RESLIM = 1000000, SYSOUT = OFF, SOLPRINT = OFF,  OPTCR= 0.01;

sets
i node /101,102,201,202,301,302,401,402,1001,2001/
m node types /home,office,other/
u attribute types /building,location,transport/
hb(i) home building /101,102/
ob(i) office building /401,402/
b(i) building /101,102,401,402/
l(i) location /201,202,301,302/
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

parameter virtual_arc(i,j)/
101.201  1
101.202  1
101.301  1
101.302  1
102.201  1
102.202  1
102.301  1
102.302  1
201.401  1
202.401  1
301.401  1
302.401  1
201.402  1
202.402  1
301.402  1
302.402  1
/;

parameter fft(i,j)/
201.301  2
201.302  4
202.301  2
202.302  3
301.201  8
301.202  8
302.201  8
302.202  8
201.202  5
202.201  5
301.302  6
302.301  6
/;

parameter capacity(i,j)/
1001.101 2
1001.102 3
101.201  2
101.202  2
101.301  2
101.302  2
102.201  3
102.202  3
102.301  3
102.302  3
201.301  2
201.302  2
202.301  2
202.302  2
201.401  2
202.401  2
301.401  2
302.401  2
201.402  3
202.402  3
301.402  3
302.402  3
401.2001 2
402.2001 3
301.201  2
301.202  2
302.201  2
302.202  2
201.202  2
202.201  2
301.302  2
302.301  2
/;

parameter intermediate_node(i);
intermediate_node(i)=(1-origin_node(i))*(1-destination_node(i));

positive variable x(i,j) traffic flow between node i and node j;
binary variable y(i,j) wether there is an arc betwwen node i and j or not;
positive variable tt(i,j) ;
variable z  total cost;

y.fx('1001','101')=1;
y.fx('1001','102')=1;
y.fx('201','301')=1;
y.fx('201','302')=1;
y.fx('202','301')=1;
y.fx('202','302')=1;
y.fx('401','2001')=1;
y.fx('402','2001')=1;
y.fx('301','201')=1;
y.fx('301','202')=1;
y.fx('302','201')=1;
y.fx('302','202')=1;
y.fx('201','202')=1;
y.fx('202','201')=1;
y.fx('301','302')=1;
y.fx('302','301')=1;


equations
cost
flow_on_node_origin(i)
flow_on_node_intermediate(i)
flow_on_node_destination(i)
arc_capacity(i,j)
assign_hb(i)
assign_ob(j)
assign_l(i)
travel_time(i,j)
;

cost..  z=e=sum((i,j)$(fft(i,j)>0),x(i,j)*tt(i,j));
flow_on_node_origin(i)$(origin_node(i)).. sum((j)$(capacity(i,j)>0.1), x(i,j)) =e= demand(i);
flow_on_node_destination(i)$(destination_node(i))..  sum((j)$(capacity(j,i)>0.1), x(j,i))=e= demand(i);
flow_on_node_intermediate(i)$(intermediate_node(i)).. sum((j)$(capacity(i,j)>0.1), x(i,j))-sum((j)$(capacity(j,i)>0.1),x(j,i))=e=0;
arc_capacity(i,j)$(virtual_arc(i,j)>0)..    x(i,j)=l=capacity(i,j)*y(i,j);
assign_hb(i)$(hb(i))..  sum(j$(l(j)),y(i,j))=e=1;
assign_ob(j)$(ob(j))..  sum(i$(l(i)),y(i,j))=e=1;
assign_l(j)$(l(j))..  sum(i$(b(i)),y(i,j)+y(j,i))=e=1;
travel_time(i,j)$(fft(i,j)>0)..  tt(i,j)=e=fft(i,j)+0.15*fft(i,j)*(abs(x(i,j)/capacity(i,j)))**4;


model urban_layout /all/;
solve urban_layout using minlp minimizing z;
display x.l, y.l, z.l;

parameter delay;
delay=sum((i,j)$(fft(i,j)>0),x.l(i,j)*(tt.l(i,j)-fft(i,j)));

File optimal_solution_result/optimal_solution_illus.dat/;
Put optimal_solution_result;
put @1,'i',@6,'j',@17,'x.l(i,j)'/
loop((i,j)$(x.l(i,j)), put @1, i.tl, @6, j.tl, @11, x.l(i,j)/);
loop((i,j)$(y.l(i,j)), put @1, i.tl, @6, j.tl, @11, y.l(i,j)/);
put  @1, 'z.l',@5, z.l,  @50, 'delay', @70, delay;

