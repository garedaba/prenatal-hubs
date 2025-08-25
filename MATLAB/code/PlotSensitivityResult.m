%%
load('SensitivityResult.mat')

figure('Position',[35 262 1324 591])

redcolor = [0.635 0.078	0.184];

Ages = 37:44;

deg = sum(GrpAvg>0,2);

for i = 1:length(Ages)
    subplot(2,4,i)
    s = scatterfit(deg,sum(GrpAvgAge(:,:,i)>0,2),36,redcolor,[],1,12);
    s.MarkerEdgeColor = 'k';
    title([num2str(Ages(i)),' weeks GA (N = ',num2str(NperAgeRange(i)),')'])
    xlabel('Degree (37-44 weeks GA)')
    ylabel(['Degree (',num2str(Ages(i)),' weeks GA)'])
    set(gca,'FontSize',12)
end

exportgraphics(gcf,'./figures/GAGrouping.png','Resolution',300)

figure('Position',[637   261   729   589])

x = 1:208;                            % X-axis values
mu = mean(DegCorrBoot,2);                  % Mean values
sigma = std(DegCorrBoot,[],2);             % Standard deviation

% Create the shaded area for mean ± std
x_shade = [x, fliplr(x)];             % X coordinates (forward and back)
y_shade = [mu + sigma; flipud(mu - sigma)];  % Upper then lower bound

hold on
fill(x_shade, y_shade, make_alpha_rgb(redcolor,.5), 'EdgeColor', 'none'); % Shaded area
plot(x, mu, 'Color',redcolor, 'LineWidth', 2);                         % Mean line
xlabel('Bootstrap sample size')
ylabel({'Correlation with the','full degree sequence'})
%title('Mean ± Std Dev')
box on
xlim([1 208])
ylim([0.8 1])
set(gca,'FontSize',20)

exportgraphics(gcf,'./figures/BootstrapResult.png','Resolution',300)