--link 你的怪兽名字
function c100017.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,99,c100017.lcheck)
	c:EnableReviveLimit()
	
	--Effect 1: Opponent cannot set cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SSET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_HAND+LOCATION_SZONE)
	e1:SetTarget(aux.TRUE)
	c:RegisterEffect(e1)
	
	--Effect 2: Decrease ATK of linked monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c100017.atktg)
	e2:SetValue(-500)
	c:RegisterEffect(e2)

	--Effect 3: Special summon tuner monster from hand or deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100017,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,100017)
	e3:SetCondition(c100017.spcon)
	e3:SetTarget(c100017.sptg)
	e3:SetOperation(c100017.spop)
	c:RegisterEffect(e3)
end

-- This function now checks if the group of materials includes at least one FIRE attribute monster.
function c100017.lcheck(g)
	return g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
end

--Effect 2 target: Only applies to monsters in the linked zones
function c100017.atktg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end

--Effect 3 condition: Trigger when link summoned
function c100017.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

--Effect 3 target: Special summon 1 Level 3 or lower Tuner monster
function c100017.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c100017.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c100017.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

--Effect 3 operation: Special summon the Tuner monster
function c100017.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,c100017.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
