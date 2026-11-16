# Mediora

Mediora provides general guidance on which medical specialties may be relevant
to selected symptoms. It is not a diagnostic tool.

## Run in Microsoft Edge

From this directory, run:

```powershell
flutter run -d edge
```

To search for nearby hospitals, allow location access when Microsoft Edge
prompts. Browser location requires a secure context; `localhost` is supported
for local development.

## Supabase login setup

The app supports username/password accounts and guest use. Supabase Auth still
requires an email or phone identifier, so Mediora maps each username to an
internal address (`<username>@accounts.mediora.example`). Users do not enter or
receive email at this address. For that reason, turn off email confirmations;
password recovery by email is not available with this username-only design.
The app never stores passwords in the profile table.

1. Create a project at [supabase.com](https://supabase.com/) and wait for its
   database to finish provisioning.
2. In the Supabase project, open **SQL Editor**, create a query, and run:

   ```sql
   create table public.profiles (
     id uuid primary key references auth.users (id) on delete cascade,
     first_name text not null,
     surname text not null,
     birthday date not null,
     address text not null,
     username text not null unique
       check (username ~ '^[a-z0-9._-]{3,24}$'),
     created_at timestamptz not null default now()
   );

   alter table public.profiles enable row level security;

   create policy "Users can view their own profile"
     on public.profiles
     for select
     to authenticated
     using ((select auth.uid()) = id);

   create function public.create_profile_for_new_user()
   returns trigger
   language plpgsql
   security definer
   set search_path = ''
   as $$
   begin
     insert into public.profiles (
       id, first_name, surname, birthday, address, username
     )
     values (
       new.id,
       new.raw_user_meta_data ->> 'first_name',
       new.raw_user_meta_data ->> 'surname',
       (new.raw_user_meta_data ->> 'birthday')::date,
       new.raw_user_meta_data ->> 'address',
       lower(new.raw_user_meta_data ->> 'username')
     );
     return new;
   end;
   $$;

   create trigger on_auth_user_created
     after insert on auth.users
     for each row execute procedure public.create_profile_for_new_user();
   ```

3. Open **Authentication → Providers → Email** and disable email
   confirmations. Since the app does not collect an actual email address,
   confirmation messages cannot be delivered.
4. Open **Project Settings → API** and copy the **Project URL** and the
   **publishable/anon key**. Do not use or ship the `service_role` key in the
   app.
5. From the project directory, start the app with both values:

   ```powershell
   flutter run -d edge --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
   ```

   Use the same Dart defines for other Flutter targets. With no keys configured,
   the app still opens and **Continue as a guest** remains available; account
   actions display a setup message.
6. Create an account in the app, then log in with the username and password.
   The trigger creates a profile row from signup metadata. Row-level security
   lets a signed-in user read only their own profile.

Names, birthday, and address are personal information. Only collect and retain
the fields your app needs, and review applicable privacy requirements before
deploying.

## 3D anatomy viewer

The symptom page renders the Human Atlas BodyParts3D model directly in Mediora's
WebView with Three.js. It does not embed the Atlas website. The app downloads
the model manifest and compressed geometry from the pinned, public
[Human Atlas model release](https://github.com/ashemag/human-atlas/tree/1c38bf35c254a891200d3cedecfd57abebe83d8d/public/models).
Tapping a model structure maps it to a Mediora body area and filters the
related symptom list. An internet connection is required for the first load.

The model data is adapted from BodyParts3D 4.0, © Database Center for Life
Science, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
The Human Atlas source and data preparation are available in the
[Human Atlas repository](https://github.com/ashemag/human-atlas); the viewer
application source is under its [MIT License](https://github.com/ashemag/human-atlas/blob/main/LICENSE).
This is an adult male reference model intended for education, not diagnosis or
treatment. See the [BodyParts3D data license](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html)
and [dataset information](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html).
