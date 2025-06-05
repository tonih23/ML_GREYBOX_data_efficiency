

offset_x = -0.13;
offset_y = 0.135;
offset_z = -0.068;

px = linspace(0, 0.15, 10)+offset_x;
r = 0.03;
t = 0.1:0.1:1;

P = [];
for  i = 1:length(px)

    p1 = px(i)*ones(10,1);
    p2 = sin(pi*2*t)'*r+offset_y;
    p3 = cos(pi*2*t)'*r+offset_z;
    P = [P;[p1,p2,p3]];
end

fid = fopen('exp.txt','w');
for i = 1:size(P,1)

    fprintf(fid, "<Marker name=""Marker_%03d"">\n",i);
    fprintf(fid,"<!--Path to a Component that satisfies the Socket 'parent_frame' of type PhysicalFrame (description: The frame to which this station is fixed.).-->\n");
    fprintf(fid,"<socket_parent_frame>/ground</socket_parent_frame>\n");
    fprintf(fid,"<!--The fixed location of the station expressed in its parent frame.-->\n");
    fprintf(fid,"<location>%6.5f %6.5f %6.5f</location>\n",P(i,1),P(i,2),P(i,3));
    fprintf(fid,"<!--Flag (true or false) specifying whether the marker is fixed in its parent frame during the marker placement step of scaling.  If false, the marker is free to move within its parent Frame to match its experimental counterpart.-->\n");
    fprintf(fid,"<fixed>true</fixed>\n");
    fprintf(fid,"</Marker>\n");
end

fclose(fid);

