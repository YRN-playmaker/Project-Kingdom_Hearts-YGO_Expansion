-- 键刃使的羁绊
function c100078.initial_effect(c)
	-- 卡片发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- ①：空场特招 (对应文本①)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100078,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,100078)
	e1:SetCondition(c100078.spcon1)
	e1:SetTarget(c100078.sptg1)
	e1:SetOperation(c100078.spop1)
	c:RegisterEffect(e1)

	-- ②：卡组拉2只 (对应文本②)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100078,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,100078+100) -- 修正了ID引用
	e2:SetTarget(c100078.target2)
	e2:SetOperation(c100078.operation2)
	c:RegisterEffect(e2)
end

----------------------------------------------------------------
-- ① 效果：空场特招 5星以上
----------------------------------------------------------------
function c100078.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 对方有怪，自己没怪
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end

function c100078.spfilter1(c,e,tp)
	return c:IsSetCard(0x208) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c100078.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(c100078.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function c100078.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c100078.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

----------------------------------------------------------------
-- ② 效果：卡组拉2只 (复杂条件)
----------------------------------------------------------------

-- 场上对象的过滤器
function c100078.filter2(c,e,tp)
	-- 必须是表侧的“键刃使”，且卡组里必须存在满足条件的“一对”怪兽
	if not (c:IsFaceup() and c:IsSetCard(0x208)) then return false end
	
	-- 获取卡组里所有潜在的可召唤怪兽
	local g=Duel.GetMatchingGroup(c100078.deck_filter,tp,LOCATION_DECK,0,nil,e,tp,c)
	
	-- 检查是否存在满足条件的子集 (2张)
	return g:CheckSubGroup(c100078.check_group,2,2,c)
end

-- 卡组单卡初步过滤 (和对象 rc 比较)
function c100078.deck_filter(c,e,tp,rc)
	return c:IsSetCard(0x208) 
		and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsAttribute(ATTRIBUTE_DARK)	   -- 不能是暗
		and c:IsRace(rc:GetRace())				  -- 相同种族
		and not c:IsCode(rc:GetCode())			  -- 不同名
		and c:GetLevel() ~= rc:GetLevel()		   -- 不同等级
		and c:GetAttribute() ~= rc:GetAttribute()   -- 不同属性
end

-- 检查选出的2张卡 g 是否互不相同，且符合条件
function c100078.check_group(g,rc)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	return tc1:GetCode() ~= tc2:GetCode()			 -- 2张卡互不同名
		and tc1:GetLevel() ~= tc2:GetLevel()		  -- 2张卡互不同级
		and tc1:GetAttribute() ~= tc2:GetAttribute()  -- 2张卡互不同属性
end

function c100078.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c100078.filter2(chkc,e,tp) end
	if chk==0 then 
		-- 这里的 Check 必须非常严谨，否则会空发
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 -- 需要2个格子
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) -- 防精灵龙
			and Duel.IsExistingTarget(c100078.filter2,tp,LOCATION_MZONE,0,1,nil,e,tp) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c100078.filter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end

function c100078.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=Duel.GetFirstTarget()
	
	-- 再次检查格子和对象
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 
		or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		
	if not rc or not rc:IsRelateToEffect(e) or not rc:IsFaceup() then return end
	
	-- 再次获取符合条件的卡组怪兽
	local g=Duel.GetMatchingGroup(c100078.deck_filter,tp,LOCATION_DECK,0,nil,e,tp,rc)
	
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 强制选2张，且满足互不相同
		local sg=g:SelectSubGroup(tp,c100078.check_group,false,2,2,rc)
		if sg then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end

	-- 自肃限制：这个回合，自己不能从额外卡组把怪兽特殊召唤
	-- 根据文本，如果是“效果处理后”才加限制：
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET) -- 注意：这里不需要 OATH
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c100078.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function c100078.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end