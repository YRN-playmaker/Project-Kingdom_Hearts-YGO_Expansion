--键刃-王国之键
function c100026.initial_effect(c)
	--装备魔法通用注册
	c:SetUniqueOnField(1,0,100026) -- (可选) 如果你想限制场上只能有一把王国之键，可以加这行
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c100026.target)
	e1:SetOperation(c100026.operation)
	c:RegisterEffect(e1)

	--装备限制
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c100026.eqlimit)
	c:RegisterEffect(e2)

	--Atk up (只加攻击力)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)

	--穿防 (Pierce)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)

	--②效果：Cost送墓 -> 特殊召唤
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(100026,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,100026)
	e5:SetCost(c100026.spcost)
	e5:SetTarget(c100026.sptg)
	e5:SetOperation(c100026.spop)
	c:RegisterEffect(e5)

	--③效果：送墓回卡组 (强制效果)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(100026,0))
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetTarget(c100026.tdtg)
	e6:SetOperation(c100026.tdop)
	c:RegisterEffect(e6)
end

-- 装备限制：名称含有「键刃使」
function c100026.eqlimit(e,c)
	return c:IsSetCard(0x208)
end

-- 装备对象选择
function c100026.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and c100026.eqlimit(e,chkc) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c100026.eqlimit) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c100026.eqlimit)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function c100026.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end

-- ==================================================================
-- ②效果：特招处理
-- ==================================================================

function c100026.costfilter(c)
	return c:IsCode(100025) and c:IsAbleToGraveAsCost() -- [指令动作-键刃变形]
end

-- Cost: 把 手卡魔法 + 自身 + 装备怪兽 一起送墓
function c100026.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if chk==0 then 
		return tc and tc:IsAbleToGraveAsCost() 
		and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(c100026.costfilter,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c100026.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	g:AddCard(c)
	g:AddCard(tc)
	Duel.SendtoGrave(g,REASON_COST)
end

function c100026.spfilter(c,e,tp)
	return c:IsCode(100003) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target: 检查额外卡组有没有索拉2nd，并且检查空位 (SendtoGrave之后会有空位)
function c100026.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		-- 这里使用 GetLocationCountFromEx，因为Cost会把怪兽腾出来，所以要传入e:GetHandler():GetEquipTarget()作为即将离场的怪
		local ec=e:GetHandler():GetEquipTarget()
		return Duel.GetLocationCountFromEx(tp,tp,ec,nil)>0 
		and Duel.IsExistingMatchingCard(c100026.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function c100026.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c100026.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 成功特招后，加上光属性自肃
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c100026.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function c100026.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT)
end

-- ==================================================================
-- ③效果：回卡组
-- ==================================================================
function c100026.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end -- 强制效果，chk==0 直接返回 true
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end

function c100026.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end