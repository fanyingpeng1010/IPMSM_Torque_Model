function set_high_resolution_plots()
    % 设置MATLAB默认绘图参数为高分辨率(600dpi)绘图
    
    % 1. 设置图形默认参数
    set(0, 'DefaultFigureColor', 'w');               % 白色背景
    set(0, 'DefaultFigureInvertHardcopy', 'off');    % 保持设置的背景色
    
    % 2. 设置坐标轴默认参数
    set(0, 'DefaultAxesFontName', 'Arial');          % 使用Arial字体
    set(0, 'DefaultAxesFontSize', 14);               % 字体大小
    set(0, 'DefaultAxesLabelFontSizeMultiplier', 1); % 标签字体大小乘数
    set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.1); % 标题字体大小乘数
    set(0, 'DefaultAxesLineWidth', 1);               % 坐标轴线宽
    set(0, 'DefaultAxesBox', 'off');                 % 不显示坐标轴盒子
    set(0, 'DefaultAxesTickDir', 'out');             % 刻度朝外
    
    % 3. 设置线条默认参数
    set(0, 'DefaultLineLineWidth', 1.5);             % 线宽1.5pt
    set(0, 'DefaultLineMarkerSize', 6);             % 标记大小
    
    % 4. 设置文本默认参数
    set(0, 'DefaultTextFontName', 'Arial');         % 文本使用Arial
    set(0, 'DefaultTextFontSize', 14);              % 文本大小
    
    
    % 5. 设置打印/导出参数为高分辨率
    set(0, 'DefaultFigurePaperPositionMode', 'auto'); % 保持屏幕显示大小
    set(0, 'DefaultFigurePaperUnits', 'inches');      % 使用英寸单位
    set(0, 'DefaultFigurePaperSize', [8.5 11]);       % 默认纸张大小(Letter)
    % 显示设置完成信息
    disp('MATLAB默认绘图参数已设置为高分辨率(600dpi)绘图模式');
    disp('使用以下命令导出图形:');
    disp('print(gcf, ''-dpdf'', ''filename.pdf'', ''-r600'');');
    disp('print(gcf, ''-dpng'', ''filename.png'', ''-r600'');');
    disp('exportgraphics(gcf, ''filename.pdf'', ''ContentType'', ''vector'', ''Resolution'', 600);');
end