import { Component } from '@angular/core';
import { CONTACT_EMAIL } from '../contact/contact.component';

// Exists mainly for the purpose of finding all places where we use
// the maintainer name s.t. we can easily adapt it in case it's ever needed.
@Component({
  selector: 'cube-trainer-maintainer-name',
  templateUrl: './maintainer-name.component.html',
})
export class MaintainerNameComponent {
  get contactEmail() {
    return CONTACT_EMAIL;
  }
}
