%% Makes all the network figures

figure('Position',[1 49 1920 962])
V = 90; thr = 0.15;
MakeRCHubPlot(V,thr)
exportgraphics(gcf,['./figures/uBrain',num2str(V),'_thr_',num2str(thr),'.png'],'Resolution',300)

%%

for V = [60 90 120]

    if ismember(V,[60 120])

        thrvals = .15;

    else

        thrvals = [.05 .25];

    end

    for thr = thrvals

        MakeRCHub_SubPlots(V,thr,'./figures')

    end

end

%%
PlotIndvHubs

%%

PlotSensitivityResult

close all