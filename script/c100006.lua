function c100006.initial_effect(c)
	-- 这张卡在自己场上只能存在1张
	c:SetUniqueOnField(1,0,100006)
	-- 激活效果：用于将这张卡发动到场上（仅起发动作用，无额外操作）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	
	-- ①：只要这张卡在场上存在，自己的「键刃使」怪兽每回合各有1次不会被战斗破坏
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c100006.indtg)
	e1:SetValue(c100006.indct)
	c:RegisterEffect(e1)
	
	-- ②：自己的「键刃使」怪兽仅在向对方怪兽攻击的伤害计算时攻击力上升100
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c100006.atktg)
	e2:SetCondition(c100006.atkcon)
	e2:SetValue(100)
	c:RegisterEffect(e2)
	
	-- ③：这张卡从场上送去墓地时发动，从卡组选择1张「键刃使」怪兽特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c100006.spcon)
	e3:SetTarget(c100006.sptg)
	e3:SetOperation(c100006.spop)
	c:RegisterEffect(e3)
end


function c100006.indtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x208)
end

function c100006.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end

--【效果②】只对「键刃使」怪兽生效，并且限定于攻击阶段伤害计算时（当该怪兽为攻击者且有对方怪兽作为攻击目标）
function c100006.atktg(e,c)
	return c:IsSetCard(0x208) and Duel.GetAttacker()==c
end
function c100006.atkcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()~=nil
end

--【效果③】条件：这张卡必须是从场上送去墓地
function c100006.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c100006.filter(c,e,tp)
	return c:IsSetCard(0x208) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c100006.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(c100006.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c100006.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c100006.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--【

