-- 键刃使·替代者
function c100046.initial_effect(c)
	-- 卡名变更 (手卡/场上)
	aux.EnableChangeCode(c,100000,LOCATION_MZONE+LOCATION_HAND)

	-- ①：不用解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100046,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c100046.ntcon)
	c:RegisterEffect(e1)
	
	-- ②：妥协召唤后的数值变化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c100046.lvop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SPSUMMON_COST)
	e3:SetOperation(c100046.lvop2)
	c:RegisterEffect(e3)

	-- ③：展示特招
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(100046,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,100046)
	e4:SetCost(c100046.spcost)
	e4:SetTarget(c100046.sptg)
	e4:SetOperation(c100046.spop)
	c:RegisterEffect(e4)

	-- ④：被解放检索装备 (修改了 Condition)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(100046,2))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_RELEASE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,100046+100)
	-- 新增 Condition
	e5:SetCondition(c100046.eqcon) 
	e5:SetTarget(c100046.eqtg)
	e5:SetOperation(c100046.eqop)
	c:RegisterEffect(e5)
end

----------------------------------------------------------------
-- ① & ② 妥协召唤逻辑
----------------------------------------------------------------
function c100046.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

function c100046.lvcon(e)
	return e:GetHandler():GetMaterialCount()==0
end

function c100046.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c100046.lvcon)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c100046.lvcon)
	e2:SetValue(0)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e2)
end

function c100046.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(0)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e2)
end

----------------------------------------------------------------
-- ③ 展示特招逻辑
----------------------------------------------------------------
function c100046.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end

function c100046.spfilter(c,e,tp)
	return c:IsCode(100002) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c100046.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c100046.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function c100046.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c100046.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

----------------------------------------------------------------
-- ④ 被解放检索逻辑 (New Condition)
----------------------------------------------------------------
-- 新增条件：检查场地区域是否有卡
function c100046.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- GetFieldCard(玩家, 区域, 序号) 返回Card对象或nil
	-- 只要 Field Zone 有卡（无论是表侧还是里侧盖放），都返回 true
	return Duel.GetFieldCard(tp,LOCATION_FZONE,0) ~= nil
end

function c100046.eqfilter(c)
	-- 检查字段 0x208 (键刃)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0x208) and c:IsAbleToHand()
end

function c100046.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100046.eqfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function c100046.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查 Condition (通常发动后不需要再检查Field，但如果被连锁炸了场地，效果通常还是处理)
	-- 但既然写在Condition里，主要是发动门槛。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100046.eqfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end