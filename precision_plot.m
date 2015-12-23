% function precision_plot()
clc,close all

plotDrawStyle10={   struct('color',[1,0,0],'lineStyle','-'),...
    struct('color',[0,1,0],'lineStyle','-'),...
    struct('color',[0,0,1],'lineStyle','-'),...
    struct('color',[0,0,0],'lineStyle','-'),...%    struct('color',[1,1,0],'lineStyle','-'),...%yellow
    struct('color',[1,0,1],'lineStyle','-'),...%pink
    struct('color',[0,1,1],'lineStyle','-'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','-'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','--'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle',':'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','-'),...%Turquoise
    };



% results = {};
% j =1;
% feat_cell = {'HOG', 'LBP', 'DSIFT', 'RAW', 'CNN'};
% for feat_name = feat_cell
%     sub_results = {};
%     i= 1;
%     
%     ave_time = zeros(3,1);
%     for mix_num = [100, 500, 800]
%         fn = fullfile('E:/Datasets/SVHN/all/htk', feat_name{1}, sprintf('mix_%d', mix_num), 'hmms', 'results.mat');
%         res = load(fn);
%         res.feat_name = feat_name{1};
%         res.mix_num = mix_num;
%         %         plot_precision(res);
%         %         sen
%         sub_results{end+1} = res;
%         ave_time(i) = sum(res.run_time(1, :))/3;
%         i = i+1;
%     end
%     plot(ave_time,plotDrawStyle10{j},'LineWidth',2,'Marker',markers(j));
%     hold on
%     j = j + 1;
%     results{end+1, 1} = sub_results;
% end
% markers = 'osd^>';
% 
% legend(feat_cell{:})
% set(gca, 'XLim', [0.9, 3.1],'XTick', [1:3], 'XTickLabel', {'100','500','800'});
%% accuracy sentence

figure;
mix_num = [100, 500, 800];
for gmm_index = 1:3
    subplot(1,3,gmm_index);
    for feat_index = 1:5
        accuracy = results{feat_index}{gmm_index}.accuracy(:,1);
        
        plot(accuracy,plotDrawStyle10{feat_index},'LineWidth',2,'Marker',markers(feat_index));
        hold on
    end
    set(gca, 'YLim',[0,0.8],'XLim', [0.9, 4.1],'XTick', [1:4], 'XTickLabel', {'1','2','3','4'});
    xlabel(sprintf('%d mixtures',mix_num(gmm_index)));
    ylabel('Accuracy');
end
hold off
legend(feat_cell{:},'Location','North','Orientation','horizontal');

%% accuracy words  

figure;
for gmm_index = 1:3
    subplot(1,3,gmm_index);
    for feat_index = 1:5
        accuracy = results{feat_index}{gmm_index}.accuracy(:,2);
        
        plot(accuracy,plotDrawStyle10{feat_index},'LineWidth',2,'Marker',markers(feat_index));
        hold on
    end
    set(gca,'YLim',[0.3,1],'XLim', [0.9, 4.1],'XTick', [1:4], 'XTickLabel', {'1','2','3','4'});
    xlabel(sprintf('%d mixtures',mix_num(gmm_index)));
    ylabel('Accuracy');
end
hold off
legend(feat_cell{:},'Location','North','Orientation','horizontal');


%% accuracy histogram
%% sentence 
figure;
hist_bar = zeros(3,5);
iters = 3;
sentence_type = 1; % sentence
for gmm_index = 1:3
    for feat_index = 1:5
        accuracy = results{feat_index}{gmm_index}.accuracy(:,sentence_type);
        hist_bar(gmm_index,feat_index) = accuracy(iters);
    end
end
bar(hist_bar,0.8,'grouped') 
set(gca,'ylim',[0,0.8])
xlabel('mixtures');
ylabel('Accuracy');
legend(feat_cell{:},'Location','North','Orientation','horizontal');
%% words
figure;
hist_bar = zeros(3,5);
sentence_type = 2; % words
iters = 3;
for gmm_index = 1:3
    for feat_index = 1:5
        accuracy = results{feat_index}{gmm_index}.accuracy(:,sentence_type);
        hist_bar(gmm_index,feat_index) = accuracy(iters);
    end
end
bar(hist_bar,0.8,'grouped')
legend(feat_cell{:},'Location','North','Orientation','horizontal');
set(gca,'ylim',[0,1])
xlabel('mixtures');
ylabel('Accuracy');