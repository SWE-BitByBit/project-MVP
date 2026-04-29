/// Tipologie di diario a cui l'utente può accedere
enum DiaryType { real_diary, fake_diary }


/// Enum corrispondente ai risultati possibili di un tentativo di login nella funzionalità dei diari
enum DiaryAccessResult { real_diary, fake_diary, error, too_many_attempts }
