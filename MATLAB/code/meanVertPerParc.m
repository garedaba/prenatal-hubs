% Get the number of mean vertices per subparcel

subdiv_size = [60 90 120];

meanSDverts = zeros(3,2);

for v = 1:3

    V = subdiv_size(v);

    LParcID = dlmread(['uBrain',num2str(V),'verts.txt']);
    
    Nparc = max(LParcID);
    Nverts = zeros(Nparc,1);

    for i = 1:Nparc
        Nverts(i) = sum(LParcID==i);  
    end

    meanSDverts(v,:) = [mean(Nverts) std(Nverts)];

    disp(['uBrain',num2str(V),' verices per subparcel: mean = ',num2str(meanSDverts(v,1)),', SD = ',num2str(meanSDverts(v,2))])

end

