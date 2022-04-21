require 'rails_helper'

describe "Card Script Submission" do
  describe "POST /card_script_submissions/" do
    it "submit a card script" do
      post "/card_script_submissions/", params: {
        card_script_submission: {
          card_name: "Snapcaster Mage",
          is_token: false,
          config: CSM_CONFIG,
          script: CSM_SCRIPT,
          comment: "My Comment"
        }
      }

      expect(response.status).to eq 302
      csm = CardScriptSubmission.last
      expect(csm.card.name).to eq "Snapcaster Mage"
      expect(csm.config).to eq CSM_CONFIG
      expect(csm.script).to eq CSM_SCRIPT
    end
    it "submit a unformatted card script" do

      post "/card_script_submissions/", params: {
        card_script_submission: {
          card_name: "Snapcaster Mage",
          is_token: false,
          config: CSM_CONFIG_UNFORMATTED,
          script: CSM_SCRIPT_UNFORMATTED,
          comment: "My Comment"
        }
      }

      expect(response.status).to eq 302
      csm = CardScriptSubmission.last
      expect(csm.card.name).to eq "Snapcaster Mage"
      expect(csm.config).to eq CSM_CONFIG
      expect(csm.script).to eq CSM_SCRIPT
    end
  end
end
CSM_CONFIG = <<-TXT
name=Snapcaster Mage
image=http://mtgimage.com/card/snapcaster%20mage.jpg
value=4.361
rarity=R
type=Creature
subtype=Human,Wizard
cost={1}{U}
pt=2/1
ability=flash
timing=main
requires_groovy_code
oracle=Flash. When Snapcaster Mage enters the battlefield, target instant or sorcery card in your graveyard gains flashback until end of turn. The flashback cost is equal to its mana cost.
TXT
CSM_CONFIG_UNFORMATTED = <<-TXT
name=Snapcaster Mage
image=http://mtgimage.com/card/snapcaster%20mage.jpg
value=4.361\r
rarity=R

type=Creature
subtype=Human,Wizard
cost={1}{U}\r

pt=2/1
ability=flash\r
 timing=main
requires_groovy_code
     oracle=Flash. When Snapcaster Mage enters the battlefield, target instant or sorcery card in your graveyard gains flashback until end of turn. The flashback cost is equal to its mana cost.
TXT
CSM_SCRIPT = <<-TXT
def A_PAYABLE_INSTANT_OR_SORCERY_CARD_FROM_YOUR_GRAVEYARD = new MagicTargetChoice(
    MagicTargetFilterFactory.PAYABLE_INSTANT_OR_SORCERY_FROM_GRAVEYARD,
    "a instant or sorcery card from your graveyard"
);
def EVENT_ACTION = {
    final MagicGame game, final MagicEvent event ->
    game.doAction(new MagicRemoveCardAction(event.getCard(),MagicLocationType.Graveyard));
    final MagicCardOnStack cardOnStack=new MagicCardOnStack(event.getCard(),event.getPlayer(),game.getPayedCost());
    cardOnStack.setMoveLocation(MagicLocationType.Exile);
    game.doAction(new MagicPutItemOnStackAction(cardOnStack));
};
[
    new MagicWhenComesIntoPlayTrigger() {
        @Override
        public MagicEvent executeTrigger(final MagicGame game, final MagicPermanent permanent, final MagicPayedCost payedCost) {
            return new MagicEvent(
                permanent,
                new MagicMayChoice(
                    A_PAYABLE_INSTANT_OR_SORCERY_CARD_FROM_YOUR_GRAVEYARD
                ),
                MagicGraveyardTargetPicker.PutOntoBattlefield,
                this,
                "PN may\$ cast target instant or sorcery card\$ from his or her graveyard, then exile it."
            );
        }
        @Override
        public void executeEvent(final MagicGame game, final MagicEvent event) {
            if (event.isYes()) {
                event.processTargetCard(game, {
                    game.addEvent(new MagicPayManaCostEvent(it,it.getCost()));
                    game.addEvent(new MagicEvent(
                        it,
                        EVENT_ACTION,
                        "Cast SN."
                    ));
                });
            }
        }
    }
]
TXT
CSM_SCRIPT_UNFORMATTED = <<-TXT
def A_PAYABLE_INSTANT_OR_SORCERY_CARD_FROM_YOUR_GRAVEYARD = new MagicTargetChoice(
\tMagicTargetFilterFactory.PAYABLE_INSTANT_OR_SORCERY_FROM_GRAVEYARD,
\t"a instant or sorcery card from your graveyard"
);

def EVENT_ACTION = {
    final MagicGame game, final MagicEvent event ->
    game.doAction(new MagicRemoveCardAction(event.getCard(),MagicLocationType.Graveyard));
    final MagicCardOnStack cardOnStack=new MagicCardOnStack(event.getCard(),event.getPlayer(),game.getPayedCost());
    cardOnStack.setMoveLocation(MagicLocationType.Exile);
    game.doAction(new MagicPutItemOnStackAction(cardOnStack));
};

[
    new MagicWhenComesIntoPlayTrigger() {
        @Override
        public MagicEvent executeTrigger(final MagicGame game, final MagicPermanent permanent, final MagicPayedCost payedCost) {
            return new MagicEvent(
                permanent,\r
                new MagicMayChoice(\r
                    A_PAYABLE_INSTANT_OR_SORCERY_CARD_FROM_YOUR_GRAVEYARD\r
                ),
                MagicGraveyardTargetPicker.PutOntoBattlefield,
                this,
                "PN may\$ cast target instant or sorcery card\$ from his or her graveyard, then exile it."
            );
        }
        @Override
        public void executeEvent(final MagicGame game, final MagicEvent event) {
            if (event.isYes()) {
                event.processTargetCard(game, {
                    game.addEvent(new MagicPayManaCostEvent(it,it.getCost()));
                    game.addEvent(new MagicEvent(
                        it,
                        EVENT_ACTION,
                        "Cast SN."
                    ));
                });
            }
        }
    }
]
TXT
