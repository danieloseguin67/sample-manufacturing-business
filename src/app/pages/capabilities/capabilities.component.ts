import { Component } from '@angular/core';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-capabilities',
  standalone: true,
  imports: [TranslatePipe],
  templateUrl: './capabilities.component.html',
  styleUrl: './capabilities.component.scss'
})
export class CapabilitiesComponent {

}
