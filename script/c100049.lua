--键刃使索拉 2nd-E
-- Synchro Monster: 键刃使 索拉 2nd
function c100049.initial_effect(c)
	-- Synchro summon: 1 tuner + 1 or more non-tuner monsters with "键刃使" in their name
	aux.EnableChangeCode(c,100000,LOCATION_MZONE)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x208),1)
	c:EnableReviveLimit()

	-- ②: When this card is Synchro Summoned, add "觉醒之力" from your deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100049,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,100049)
	e2:SetCondition(c100049.thcon)
	e2:SetTarget(c100049.thtg)
	e2:SetOperation(c100049.thop)
	c:RegisterEffect(e2)

	-- ③: Target 1 Xyz Monster on your field, attach 1 Spell/Trap from either player's graveyard to it as Xyz Material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100049,2))
	e3:SetCategory(CATEGORY_ATTACH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,100049+100)
	e3:SetTarget(c100049.xyztg)
	e3:SetOperation(c100049.xyzop)
	c:RegisterEffect(e3)
end

-- ② Condition: This card must be Synchro Summoned
function c100049.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- ② Target: Search "觉醒之力"
function c100049.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,100022) end  -- Assuming "觉醒之力" has card ID 100100
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ② Operation: Add "觉醒之力" to hand
function c100049.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,nil,100022)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

-- ③ Target: Target 1 Xyz Monster, and 1 Spell/Trap from either player's graveyard
function c100049.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,TYPE_SPELL+TYPE_TRAP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,1,nil)
end

-- ③ Operation: Attach the selected Spell/Trap to the Xyz Monster as material
function c100049.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_XYZ) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,TYPE_SPELL+TYPE_TRAP)
		if #g>0 then
			Duel.Overlay(tc,g)
		end
	end
end

