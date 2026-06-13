// Façade d'authentification : pseudo + PIN → Supabase Auth
// Convention : l'email technique est toujours pseudo@campagne.local
// Le PIN sert de mot de passe — jamais stocké en clair côté appli.
import { supabase } from './supabase'

function emailDepseudo(pseudo) {
  return `${pseudo.trim().toLowerCase()}@campagne.local`
}

export async function inscrire(pseudo, pin) {
  const email = emailDepseudo(pseudo)

  const { data, error } = await supabase.auth.signUp({ email, password: pin })
  if (error) throw error

  // Insère la ligne joueur liée au compte Auth tout juste créé
  const { error: errJoueur } = await supabase
    .from('joueurs')
    .insert({ id: data.user.id, pseudo: pseudo.trim() })
  if (errJoueur) throw errJoueur
}

export async function connecter(pseudo, pin) {
  const email = emailDepseudo(pseudo)
  const { error } = await supabase.auth.signInWithPassword({ email, password: pin })
  if (error) throw error
}

export async function deconnecter() {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}
