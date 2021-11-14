import { NgModule } from '@angular/core';
import { UserComponent } from './users/user.component';
import { AchievementsComponent } from './users/achievements.component';
import { AchievementGrantsComponent } from './users/achievement-grants.component';
import { AchievementComponent } from './users/achievement.component';
import { MessageComponent } from './users/message.component';
import { MessagesComponent } from './users/messages.component';
import { NewColorSchemeComponent } from './users/new-color-scheme.component';
import { NewLetterSchemeComponent } from './users/new-letter-scheme.component';
import { SignupComponent } from './users/signup.component';
import { LoginComponent } from './users/login.component';
import { LogoutComponent } from './users/logout.component';
import { AccountDeletedComponent } from './users/account-deleted.component';
import { ModesComponent } from './modes/modes.component';
import { NewModeComponent } from './modes/new-mode.component';
import { TrainerComponent } from './trainer/trainer.component';
import { PrivacyPolicyComponent } from './footer/privacy-policy.component';
import { TermsAndConditionsComponent } from './footer/terms-and-conditions.component';
import { RouterModule, Routes } from '@angular/router';
import { environment } from './../environments/environment';

const routes: Routes = [
  { path: 'signup', component: SignupComponent },
  { path: 'login', component: LoginComponent },
  { path: 'logout', component: LogoutComponent },
  { path: 'account_deleted', component: AccountDeletedComponent },
  { path: 'modes', component: ModesComponent },
  { path: 'achievements', component: AchievementsComponent },
  { path: 'achievements/:achievementKey', component: AchievementComponent },
  { path: 'users/:userId', component: UserComponent },
  { path: 'users/:userId/achievement_grants', component: AchievementGrantsComponent },
  { path: 'users/:userId/messages', component: MessagesComponent },
  { path: 'users/:userId/messages/:messageId', component: MessageComponent },
  { path: 'color_schemes/new', component: NewColorSchemeComponent },
  { path: 'letter_schemes/new', component: NewLetterSchemeComponent },
  { path: 'modes/new', component: NewModeComponent },
  { path: 'trainer/:modeId', component: TrainerComponent },
  { path: 'privacy_policy', component: PrivacyPolicyComponent },
  { path: 'terms_and_conditions', component: TermsAndConditionsComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes, { enableTracing: !environment.production })],
  exports: [RouterModule]
})
export class AppRoutingModule { }
