import { Component, OnInit } from '@angular/core';
import { UserService } from './user.service';
import { User } from './user';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'user',
  template: `
<h1>{{userName}}</h1>
<messages></messages>
<achievement-grants></achievement-grants>
`
})
export class UserComponent implements OnInit {
  userId$: Observable<number>;
  user: User | undefined = undefined;

  constructor(private readonly userService: UserService,
	      private readonly activatedRoute: ActivatedRoute) {
    this.userId$ = this.activatedRoute.params.pipe(map(p => p.userId));
  }

  get userName() {
    return this.user?.name;
  }

  ngOnInit() {
    this.userId$.subscribe(userId => {
      this.userService.show(userId);
    });
  }
}
