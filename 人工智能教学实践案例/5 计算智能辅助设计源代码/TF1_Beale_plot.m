
clear all
home
close all
tic


plot_font_size = 14;
plot_linewidth = 2;

%% initialise input data
% x in [-1, 2]
x0   = -4.5;
x2   = 4.5;
step = 0.1;

xdata1 = x0: step: x2;
xdata2 = x0: step: x2;

%%%%%%%%%%%% data generation

[ XXdata1 , XXdata2 ] = meshgrid( xdata1 , xdata2 );

YYdata = TF1_Beale( XXdata1 , XXdata2 );

meshc( XXdata1 , XXdata2 , YYdata);
set(gca,'fontsize',plot_font_size) ;
xlabel('x1','fontsize',plot_font_size);
ylabel('x2','fontsize',plot_font_size);
zlabel('f','fontsize',plot_font_size);
axis tight


%% save figures
saveas(gcf,'TF1_Beale', 'pdf');
saveas(gcf,'TF1_Beale', 'jpg');
saveas(gcf,'TF1_Beale', 'eps');
saveas(gcf,'TF1_Beale', 'fig');

toc
% TF1_Beale_plot End