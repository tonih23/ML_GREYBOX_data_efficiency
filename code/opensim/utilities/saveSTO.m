function saveSTO(D,param)
Nsamples = length(D.data(:,1)); Nstates = length(param.statesNames);

str = strjoin(param.statesNames,'\t');
header = ['simulation \nversion=1 \nnRows=' num2str(Nsamples) ' \nnColumns=' num2str(Nstates+1) '\ninDegrees=no \nendheader \ntime	' str '\n'];
fid = fopen('../results/simulation.sto','w');
fprintf(fid,header); fclose(fid);
fid = fopen('../results/simulation.sto','a+');
for i = 1:Nsamples
    fprintf(fid,'\t%f',D.data(i,:)); fprintf(fid,'\n');
end
fclose(fid);