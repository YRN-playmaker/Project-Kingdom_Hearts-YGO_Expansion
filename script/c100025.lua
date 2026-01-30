--通常魔法卡
function c100025.initial_effect(c)
    -- ①效果：检索装备魔法卡
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,100025)
    e1:SetCost(c100025.cost)
    e1:SetTarget(c100025.target)
    e1:SetOperation(c100025.operation)
    c:RegisterEffect(e1)

    -- ②效果：墓地效果
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,100025)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(c100025.grave_target)
    e2:SetOperation(c100025.grave_operation)
    c:RegisterEffect(e2)
end

-- ①效果的cost：送1张场上的装备魔法卡去墓地
function c100025.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_SZONE,0,1,nil,TYPE_EQUIP) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_SZONE,0,1,1,nil,TYPE_EQUIP)
    Duel.SendtoGrave(g,REASON_COST)
end

-- ①效果的target：从卡组检索1张不同名字的装备魔法卡
function c100025.filter(c)
    return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function c100025.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c100025.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ①效果的operation：将选中的装备魔法卡加入手牌
function c100025.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c100025.filter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ②效果的target：选择墓地中的1只「键刃使」怪兽
function c100025.grave_filter(c)
    return c:IsSetCard(0x208) and c:IsAbleToHand()
end
function c100025.grave_target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c100025.grave_filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c100025.grave_filter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,c100025.grave_filter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end

-- ②效果的operation：将魔法卡返回卡组，并将选中的怪兽加入手牌
function c100025.grave_operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
        end
    end
end


