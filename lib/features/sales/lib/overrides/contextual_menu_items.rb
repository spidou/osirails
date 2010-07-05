module Osirails
  module ContextualMenu
    class Section
      @@section_titles.update({ :order_progress   => "Avancement du projet",
                                :order            => "Dossier",
                                :graphic_items    => "Ressources graphiques",
                                :mockup           => "Maquette",
                                :graphic_document => "Document graphique",
                                :spool_items      => "Travaux en attente",
                                :survey_step      => "Étape \"Survey\"",
                                :quote_step       => "Étape \"Devis\"",
                                :press_proof_step => "Étape \"BAT\"",
                                :delivery_step    => "Étape \"Livraison\"",
                                :invoice_step     => "Étape \"Factures\"",
                                :quote            => "Devis",
                                :press_proof      => "BAT",
                                :delivery_note    => "Bon de livraison",
                                :invoice          => "Facture" })
    end
  end
end
