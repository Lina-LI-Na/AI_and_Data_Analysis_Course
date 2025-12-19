clear all
home
close all
tic


plot_font_size = 14;
plot_linewidth = 2;

%% initialise input data
% x in [-40, 40]
x0   = -40;
x2   = 40;
step = 0.1;

xdata1 = x0: step: x2;
xdata2 = x0: step: x2;

%%%%%%%%%%%% data generation

[ XXdata1 , XXdata2 ] = meshgrid( xdata1 , xdata2 );

datalength = length(XXdata1);

for ind = 1 : 1: datalength
    for jnd =  1 : 1: datalength
        %% calculation
        
        YYdata(ind,jnd) = TF1_Ackley([XXdata1(ind,jnd),XXdata2(ind,jnd)]);
        
    end
    
end


meshc( XXdata1 , XXdata2 , YYdata);
% surf( XXdata1 , XXdata2 , YYdata);
set(gca,'fontsize',plot_font_size) ;
xlabel('x','fontsize',plot_font_size);
ylabel('x','fontsize',plot_font_size);
zlabel('f','fontsize',plot_font_size);
axis tight


%% save figures
saveas(gcf,'TF1_Ackley', 'pdf');
saveas(gcf,'TF1_Ackley', 'jpg');
saveas(gcf,'TF1_Ackley', 'eps');
saveas(gcf,'TF1_Ackley', 'fig');

toc
% plot_font_size End