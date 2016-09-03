function [F,E,A,G,SumTradeFee, portFreez] = CPPIStr(PortValue,Riskmulti,GuarantRatio,TradeDayTimeLong,TradeDayOfYear,adjustCycle,RisklessReturn,TradeFee,SData)

%input:
%PortValue ��Ʒ��ϳ�ʼֵ
%Riskmulti:CPPI���Է��ճ���
%GuarantRatio:��Ʒ������
%TradeDayTimeLong:��Ʒ���ޣ�������
%TradeDayOfYear: ��Ʒÿ�꽻���գ���250��
%adjustCycle:��Ʒ����ģ�͵������ڣ�����ÿ10�������յ���һ�Ρ�
%RisklessReturn: �޷����ʲ��껯������
%TradeFee:���׷���
%SData: ģ������ʲ��������У������˶�
%output:
%F:���飬��t������Ϊtʱ�̰�ȫ����
%E:���飬��t������Ϊtʱ�̿�Ͷ�����ʲ�����
%A:���飬��t������Ϊtʱ�̲�Ʒ��ֵ
%G:���飬��t������Ϊtʱ�̿�Ͷ��g�����ʲ�����
%SumTradeFee���ܽ��׷���
%portFeez:��Ͻ����Ƿ����ƽ�֣�0δ 1����

SumTradeFee = 0;
% F,E,A,G length = N + 1
F = zeros(1, TradeDayTimeLong + 1);
E = zeros(1, TradeDayTimeLong + 1);
A = zeros(1, TradeDayTimeLong + 1);
G = zeros(1, TradeDayTimeLong + 1);

%��ʼ����ʲ�
A(1) = PortValue;
%��ʼ��ȫ����
F(1) = GuarantRatio * PortValue * exp(-RisklessReturn * TradeDayTimeLong/TradeDayOfYear);
%��ʼ�����ʲ�
E(1) = max(0, Riskmulti * (A(1)-F(1)));
%�޷����ʲ�
G(1) = A(1) - E(1);

%�Ƿ�ƽ�� 
portFreez = 0;
%����ģ��
for i = 2: TradeDayTimeLong + 1
    E(i) = E(i-1) * (1 + (SData(i) - SData(i-1))/(1+SData(i-1)));
    G(i) = G(i-1) * (1 + RisklessReturn/TradeDayOfYear);
    A(i) = E(i) + G(i);
    F(i) = GuarantRatio * PortValue * exp(- RisklessReturn * (TradeDayTimeLong - i + 1)/TradeDayOfYear);
    
    %�ж��Ƿ����
    if mod(i,adjustCycle) == 0 %���ڵ���
        temp = E(i);
        E(i) = max(0, Riskmulti * (A(i) - F(i)));
        SumTradeFee = SumTradeFee + TradeFee * abs(E(i) - temp);
        G(i) = A(i) - E(i) - TradeFee * abs(E(i) - temp);
    end
    %�ж��Ƿ�ƽ��
    if E(i) == 0
        A(i) = G(i);
        portFreez = 1;
    end
end
