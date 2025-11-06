import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslatePipe } from '../../pipes/translate.pipe';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-portal',
  standalone: true,
  imports: [CommonModule, TranslatePipe, FormsModule],
  templateUrl: './portal.component.html',
  styleUrl: './portal.component.scss'
})
export class PortalComponent {
  isLoggedIn = false;
  username = '';
  password = '';

  login() {
    // This is a placeholder for demonstration
    if (this.username && this.password) {
      this.isLoggedIn = true;
    }
  }

  logout() {
    this.isLoggedIn = false;
    this.username = '';
    this.password = '';
  }
}
