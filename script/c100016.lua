--link 史迪奇
function c100016.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,99,c100016.lcheck)
	c:EnableReviveLimit()
	
	--Effect 1: Inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100016,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,100016)
	e1:SetCondition(c100016.damcon)
	e1:SetOperation(c100016.damop)
	c:RegisterEffect(e1)
	
	--Effect 2: Tribute to Special Summon from Graveyard
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100016,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,100016+1)
	e2:SetCost(c100016.spcost)
	e2:SetTarget(c100016.sptg)
	e2:SetOperation(c100016.spop)
	c:RegisterEffect(e2)
end




function c100016.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x208)
end
function c100016.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function c100016.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetLinkedGroup()
	local atk=0
	local tc=g:GetFirst()
	while tc do
		if tc:IsFaceup() then  -- 只要是表侧表示，都会计算攻击力
			atk=atk+tc:GetBaseAttack()
		end
		tc=g:GetNext()
	end
	if atk>0 then
		Duel.Damage(1-tp,atk/2,REASON_EFFECT)
	end
end

-- Cost: Tribute this card
function c100016.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

-- Target: Select 1 "Keyblade Wielder" monster from the Graveyard
function c100016.spfilter(c,e,tp)
	return c:IsSetCard(0x208) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function c100016.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c100016.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

-- Operation: Special Summon the targeted monster
function c100016.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectTarget(tp,c100016.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

