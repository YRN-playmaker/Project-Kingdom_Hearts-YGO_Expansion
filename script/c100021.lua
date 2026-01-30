--键刃使 索拉final from
function c100021.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x208),2)
	c:EnableReviveLimit()  
--damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100021,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c100021.condition)
	e1:SetTarget(c100021.target)
	e1:SetOperation(c100021.operation)
	c:RegisterEffect(e1)



--Destroy

local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100021,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c100021.dcon)
	e2:SetTarget(c100021.dtg)
	e2:SetOperation(c100021.dop)
	c:RegisterEffect(e2)




 --indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c100021.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function c100021.indtg(e,c)
	return c:IsType(TYPE_MONSTER) and e:GetHandler():GetLinkedGroup():IsContains(c)
end


--------------------------------------

function c100021.dcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function c100021.dfilter(c,e,tp)
	return not c:IsLinkState()  and c:IsType(TYPE_MONSTER)
end


function c100021.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lg=Duel.GetMatchingGroup(c100021.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,lg,lg:GetCount(),0,0)
end

function c100021.dop(e,tp,eg,ep,ev,re,r,rp)
	local lg=Duel.GetMatchingGroup(c100021.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.Destroy(lg,REASON_EFFECT)
end














---------------------------------------
-- c:GetLinkedGroupCount()*500

function c100021.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function c100021.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local ct=c:GetLinkedGroupCount()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
function c100021.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=e:GetHandler():GetLinkedGroupCount()
	Duel.Damage(p,d*500,REASON_EFFECT)
end













