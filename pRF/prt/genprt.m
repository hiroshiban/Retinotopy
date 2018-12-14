
%% polar data
% total volumes: 1:8 9:1:38 39:1:68 69:1:98 99:1:128 129:1:158 159:1:188 189:196
fix=[1,8;189,196];
stimvols=[9:1:38;39:1:68;69:1:98;99:1:128;129:1:158;159:1:188]';
colors=[round(255*rainbow(30))];
step=12; %deg

%% processing cw
prt=BVQXfile('new:prt');

prt.Experiment='Retinotopy CW';
prt.ResolutionOfTime='Volumes';
prt.ReferenceFuncThick=2;
prt.NrOfConditions=31;

prt.Cond(1).ConditionName={'Fix'};
prt.Cond(1).NrOfOnOffsets=2;
prt.Cond(1).OnOffsets=fix;
prt.Cond(1).Weights=[1;1];
prt.Cond(1).Color=[195,195,195];

for ii=1:1:30
  prt.Cond(ii+1).ConditionName={sprintf('deg%03d',step*(ii-1))};
  prt.Cond(ii+1).NrOfOnOffsets=6;
  prt.Cond(ii+1).OnOffsets=[(stimvols(ii,:))' (stimvols(ii,:))'];
  prt.Cond(ii+1).Weights=[1;1;1;1;1;1];
  prt.Cond(ii+1).Color=colors(ii,:);
end

prt.SaveAs('clockwise.prt');


%% processing ccw
prt=BVQXfile('new:prt');

prt.Experiment='Retinotopy CCW';
prt.ResolutionOfTime='Volumes';
prt.ReferenceFuncThick=2;
prt.NrOfConditions=31;

prt.Cond(1).ConditionName={'Fix'};
prt.Cond(1).NrOfOnOffsets=2;
prt.Cond(1).OnOffsets=fix;
prt.Cond(1).Weights=[1;1];
prt.Cond(1).Color=[195,195,195];

for ii=1:1:30
  prt.Cond(ii+1).ConditionName={sprintf('deg%03d',step*(30-ii))};
  prt.Cond(ii+1).NrOfOnOffsets=6;
  prt.Cond(ii+1).OnOffsets=[(stimvols(ii,:))' (stimvols(ii,:))'];
  prt.Cond(ii+1).Weights=[1;1;1;1;1;1];
  prt.Cond(ii+1).Color=colors(30-ii+1,:);
end

prt.SaveAs('countercw.prt');


%% eccentricity, expansion data
% total volumes: 1:8 9:1:33 34:38 39:1:63 64:68 69:1:93 94:98 99:1:123 124:128 129:1:153 154:158 159:1:183 184:188 189:196
fix=[1,8;34,38;64,68;94,98;124,128;154,158;184,196];
stimvols=[9:1:33;39:1:63;69:1:93;99:1:123;129:1:153;159:1:183]';
colors=[round(255*rainbow(25))];
step=1; %deg

%% processing exp
prt=BVQXfile('new:prt');

prt.Experiment='Retinotopy EXP';
prt.ResolutionOfTime='Volumes';
prt.ReferenceFuncThick=2;
prt.NrOfConditions=26;

prt.Cond(1).ConditionName={'Fix'};
prt.Cond(1).NrOfOnOffsets=7;
prt.Cond(1).OnOffsets=fix;
prt.Cond(1).Weights=[1;1;1;1;1;1;1];
prt.Cond(1).Color=[195,195,195];

for ii=1:1:25
  prt.Cond(ii+1).ConditionName={sprintf('ecc%03d',ii)};
  prt.Cond(ii+1).NrOfOnOffsets=6;
  prt.Cond(ii+1).OnOffsets=[(stimvols(ii,:))' (stimvols(ii,:))'];
  prt.Cond(ii+1).Weights=[1;1;1;1;1;1];
  prt.Cond(ii+1).Color=colors(ii,:);
end

prt.SaveAs('expansion.prt');


%% eccentricity, contraction data
% total volumes: 1:8 9:13 14:1:38 39:43 44:1:68 69:73 74:1:98 99:103 104:1:128 129:133 134:1:158 159:163 164:1:188 189:196
fix=[1,13;39,43;69,73;99,103;129,133;159,163;189,196];
stimvols=[14:1:38;44:1:68;74:1:98;104:1:128;134:1:158;164:1:188]';
colors=[round(255*rainbow(25))];
step=1; %deg

%% processing exp
prt=BVQXfile('new:prt');

prt.Experiment='Retinotopy CONTRA';
prt.ResolutionOfTime='Volumes';
prt.ReferenceFuncThick=2;
prt.NrOfConditions=26;

prt.Cond(1).ConditionName={'Fix'};
prt.Cond(1).NrOfOnOffsets=7;
prt.Cond(1).OnOffsets=fix;
prt.Cond(1).Weights=[1;1;1;1;1;1;1];
prt.Cond(1).Color=[195,195,195];

for ii=1:1:25
  prt.Cond(ii+1).ConditionName={sprintf('ecc%03d',25-ii)};
  prt.Cond(ii+1).NrOfOnOffsets=6;
  prt.Cond(ii+1).OnOffsets=[(stimvols(ii,:))' (stimvols(ii,:))'];
  prt.Cond(ii+1).Weights=[1;1;1;1;1;1];
  prt.Cond(ii+1).Color=colors(25-ii+1,:);
end

prt.SaveAs('contraction.prt');
