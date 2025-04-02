%% 工况3：(-50A,50A,10000RPM)
id_exc = -50;
iq_exc = 50;
Pn = 4;
Angle = linspace(0,2*pi,97);
omega_m = 10000;
omega_e = Pn*omega_m*2*pi/60;
% FEA数据读取
FluxD_sc = readmatrix("FEA_Torque_Data.csv","Range","B2:B98");
FluxQ_sc = readmatrix("FEA_Torque_Data.csv","Range","C2:C98");
Torque_FEA = readmatrix("FEA_Torque_Data.csv","Range","D2:D98");
PFe_e_s = readmatrix("FEA_IronLoss_Data.csv","Range","B2:B98");
PFe_h_s = readmatrix("FEA_IronLoss_Data.csv","Range","C2:C98"); 
Torque_Cogging = readmatrix("FEA_Cogging_Torque.csv","Range","B2:B98");
Torque_Cogging = Torque_Cogging/1000;   % [mNm]--> [Nm]

% 传统转矩计算方法
Te_Con = 1.5*Pn*(FluxD_sc.*iq_exc - FluxQ_sc.*id_exc);

% Wco_d 计算
id_sc = -50:5:0;
FluxD_Data = readmatrix("FluxD_constant_iq.csv","Range","C2:C1068");
for i = 1:97
    varName = sprintf('FluxD_Angle%d', i);
    startIdx = i;
    endIdx = 971 + (i - 1);
    eval([varName, ' = FluxD_Data(', num2str(startIdx), ':97:', num2str(endIdx), ',1);']);
end
for i = 1:97
    varName = sprintf('FluxD_Angle%d', i); 
    eval(['CoE_D_Angle(1,', num2str(i), ') = trapz(id_sc, ', varName, ');']);
end
% Wco_q 计算
iq_sc = 0:5:50;
FluxQ_Data = readmatrix("FluxQ_constant_id.csv","Range","C2:C1068");
for i = 1:97
    varName = sprintf('FluxQ_Angle%d', i);
    startIdx = i;
    endIdx = 971 + (i - 1);
    eval([varName, ' = FluxQ_Data(', num2str(startIdx), ':97:', num2str(endIdx), ',1);']);
end
for i = 1:97
    varName = sprintf('FluxQ_Angle%d', i);
    eval(['CoE_Q_Angle(1,', num2str(i), ') = trapz(iq_sc, ', varName, ');']);
end
% idq,Fe分量计算
dFluxD_sc_dAngle = gradient(FluxD_sc, Angle);
dFluxQ_sc_dAngle = gradient(FluxQ_sc, Angle);
for i = 1:1:97
    idi_s(i,1) = ( PFe_e_s(i,1)*FluxQ_sc(i,1)^2/((FluxQ_sc(i,1)^2 + FluxD_sc(i,1)^2)) + PFe_h_s(i,1)*FluxD_sc(i,1)^2/((FluxQ_sc(i,1)^2 + FluxD_sc(i,1)^2)) )/( -omega_e*FluxQ_sc(i,1)+omega_e*dFluxD_sc_dAngle(i,1) );
    iqi_s(i,1) = ( PFe_e_s(i,1)*FluxD_sc(i,1)^2/((FluxQ_sc(i,1)^2 + FluxD_sc(i,1)^2)) + PFe_h_s(i,1)*FluxQ_sc(i,1)^2/((FluxQ_sc(i,1)^2 + FluxD_sc(i,1)^2)) )/( omega_e*FluxD_sc(i,1)+omega_e*dFluxQ_sc_dAngle(i,1) );
end
% idq,mag分量计算
for i = 1:1:97
    idm_s(i,1) = id_exc - idi_s(i,1);
    iqm_s(i,1) = iq_exc - iqi_s(i,1);
end

% 不考虑铁损因素的转矩解析模型
for i = 1:1:97
    Torque_avg_1(i,1) = 1.5*Pn*(FluxD_sc(i,1)*iq_exc - FluxQ_sc(i,1)*id_exc);
end
delta_CoE_Angle = CoE_Q_Angle - CoE_D_Angle;
dCoE_dAngle = gradient(delta_CoE_Angle, Angle);      
Torque_ripple = 1.5*Pn*dCoE_dAngle;
Torque_ripple = Torque_ripple';
Torque_Eqs_1 = Torque_avg_1 + Torque_ripple + Torque_Cogging;

% 考虑铁损因素的转矩解析模型
for i = 1:1:97
    Te_e_Fe(i,1) = 1.5*Pn*(dFluxD_sc_dAngle(i,1)*idi_s(i,1) + dFluxQ_sc_dAngle(i,1)*iqi_s(i,1));
end
for i = 1:1:97
    Torque_avg_2(i,1) = 1.5*Pn*(FluxD_sc(i,1)*iqm_s(i,1) - FluxQ_sc(i,1)*idm_s(i,1));
end
Torque_Eqs_2 = Torque_avg_2 + Torque_ripple - Te_e_Fe + Torque_Cogging ;

% 转矩计算结果对比
set_high_resolution_plots;
figure(1)
plot(Angle,Torque_FEA,"Color",[0.90, 0.29, 0.23]);  % 红色（FEA）
hold on; grid on;
plot(Angle,Te_Con,"Color",[0.20, 0.60, 0.80]);      % 蓝色（传统转矩计算）
plot(Angle,Torque_Eqs_1,"Color",[0.47, 0.67, 0.19]);% 绿色（不考虑铁损因素）
plot(Angle,Torque_Eqs_2,"Color",[0.95, 0.76, 0.06]);% 黄色（考虑铁损因素）
xlim([0 2*pi])

% 误差分析
% 绝对误差
Abs_error_TeCon   = abs(Torque_FEA - Te_Con);
Abs_error_TeEqs_1 = abs(Torque_FEA - Torque_Eqs_1);
Abs_error_TeEqs_2 = abs(Torque_FEA - Torque_Eqs_2);
% 最大绝对误差
Max_error_TeCon   = max(abs(Torque_FEA - Te_Con));
Max_error_TeEqs_1 = max(abs(Torque_FEA - Torque_Eqs_1));
Max_error_TeEqs_2 = max(abs(Torque_FEA - Torque_Eqs_2));
% 累积绝对误差
Cum_error_TeCon   = sum(abs(Torque_FEA - Te_Con));
Cum_error_TeEqs_1 = sum(abs(Torque_FEA - Torque_Eqs_1));
Cum_error_TeEqs_2 = sum(abs(Torque_FEA - Torque_Eqs_2));
% 平均累积绝对误差
Num = size(Torque_FEA)
Mae_error_TeCon   = (Cum_error_TeCon)/Num(1,1);
Mae_error_TeEqs_1 = (Cum_error_TeEqs_1)/Num(1,1);
Mae_error_TeEqs_2 = (Cum_error_TeEqs_2)/Num(1,1);


error_metrics = [Max_error_TeCon, Max_error_TeEqs_1, Max_error_TeEqs_2;
                 Mae_error_TeCon, Mae_error_TeEqs_1, Mae_error_TeEqs_2];
% 绘制误差分组柱状图
figure(2)
hb = bar(error_metrics, 'grouped');
hold on; grid on
colors = [0.20, 0.60, 0.80;  % 蓝色（传统转矩计算）
          0.47, 0.67, 0.19;  % 绿色（不考虑铁损因素）
          0.95, 0.76, 0.06]; % 黄色（考虑铁损因素）
for k = 1:3
    hb(k).FaceColor = colors(k, :);
    hb(k).EdgeColor = 'k';
end
for i = 1:2 % 指标数（MAE, MCAE）
    for j = 1:3 % 模型数
        text(hb(j).XEndPoints(i), hb(j).YEndPoints(i) + 0.05*max(error_metrics(:)), ...
            sprintf('%.2f', error_metrics(i,j)), ...
            'HorizontalAlignment', 'center');
    end
end

figure(3)
plot(Angle,Abs_error_TeCon,"Color",[0.20, 0.60, 0.80]);      % 蓝色（传统转矩计算）
hold on; grid on;
plot(Angle,Abs_error_TeEqs_1,"Color",[0.47, 0.67, 0.19]);% 绿色（不考虑铁损因素）
plot(Angle,Abs_error_TeEqs_2,"Color",[0.95, 0.76, 0.06]);% 黄色（考虑铁损因素）
xlim([0 2*pi])  

