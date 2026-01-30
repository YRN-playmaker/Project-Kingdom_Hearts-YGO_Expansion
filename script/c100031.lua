-- 效果怪兽卡 c100031
function c100031.initial_effect(c)

	-- ① 丢弃1张魔法卡，从卡组特殊召唤1只「DS」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100031,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,100031)
	e1:SetCost(c100031.spcost)
	e1:SetTarget(c100031.sptg)
	e1:SetOperation(c100031.spop)
	c:RegisterEffect(e1)

	-- ② 装备状态特招自己
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100031,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c100031.eqcon)
	e2:SetTarget(c100031.eqspetg)
	e2:SetOperation(c100031.eqspetop)
	c:RegisterEffect(e2)

	-- ③ 自己场上有5星·5阶怪兽时，这张卡等级变为5
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100031,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,100031+100)
	e3:SetCondition(c100031.lvcon)
	e3:SetOperation(c100031.lvop)
	c:RegisterEffect(e3)
end

-- ①：丢弃1张魔法卡作为代价
function c100031.spellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end

function c100031.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100031.spellfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c100031.spellfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end

function c100031.spfilter(c,e,tp)
	return c:IsSetCard(0x209) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c100031.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c100031.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function c100031.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c100031.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ②：装备状态自己特招
function c100031.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetEquipTarget()~=nil
end

function c100031.eqspetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function c100031.eqspetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ③：有5星·5阶怪兽时变为5星
function c100031.lvfilter(c)
	return (c:IsLevel(5) or c:IsRank(5)) and c:IsFaceup()
end

function c100031.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c100031.lvfilter,tp,LOCATION_MZONE,0,1,nil)
end

function c100031.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(5)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
