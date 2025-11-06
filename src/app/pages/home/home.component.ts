import { Component, OnInit, OnDestroy, HostListener } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, TranslatePipe],
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss'
})
export class HomeComponent implements OnInit, OnDestroy {
  currentSlide = 0;
  autoPlayInterval: any;
  slidesToShow = 2; // Number of slides to show at once
  
  capabilities = [
    {
      title: 'HOME.CNC_MACHINING',
      description: 'HOME.CNC_MACHINING_DESC'
    },
    {
      title: 'HOME.INJECTION_MOLDING',
      description: 'HOME.INJECTION_MOLDING_DESC'
    },
    {
      title: 'HOME.QUALITY_ASSURANCE',
      description: 'HOME.QUALITY_ASSURANCE_DESC'
    },
    {
      title: 'HOME.CUSTOM_FABRICATION',
      description: 'HOME.CUSTOM_FABRICATION_DESC'
    }
  ];

  ngOnInit() {
    this.updateSlidesToShow();
    this.startAutoPlay();
  }

  ngOnDestroy() {
    this.stopAutoPlay();
  }

  @HostListener('window:resize')
  onResize() {
    this.updateSlidesToShow();
  }

  updateSlidesToShow() {
    const width = window.innerWidth;
    if (width >= 1200) {
      this.slidesToShow = 2; // Desktop: show 2 cards
    } else if (width >= 768) {
      this.slidesToShow = 2; // Tablet: show 2 cards
    } else {
      this.slidesToShow = 1; // Mobile: show 1 card
    }
    // Reset to first slide if current position is invalid
    const maxSlide = this.getMaxSlide();
    if (this.currentSlide > maxSlide) {
      this.currentSlide = 0;
    }
  }

  getMaxSlide(): number {
    return Math.max(0, this.capabilities.length - this.slidesToShow);
  }

  startAutoPlay() {
    this.autoPlayInterval = setInterval(() => {
      this.nextSlide();
    }, 5000); // Change slide every 5 seconds
  }

  stopAutoPlay() {
    if (this.autoPlayInterval) {
      clearInterval(this.autoPlayInterval);
    }
  }

  nextSlide() {
    const maxSlide = this.getMaxSlide();
    if (this.currentSlide < maxSlide) {
      this.currentSlide++;
    } else {
      this.currentSlide = 0; // Loop back to start
    }
  }

  prevSlide() {
    if (this.currentSlide > 0) {
      this.currentSlide--;
    } else {
      this.currentSlide = this.getMaxSlide(); // Loop to end
    }
  }

  goToSlide(index: number) {
    const maxSlide = this.getMaxSlide();
    this.currentSlide = Math.min(index, maxSlide);
    this.stopAutoPlay();
    this.startAutoPlay();
  }

  getTransform(): string {
    const cardWidth = 100 / this.slidesToShow;
    return `translateX(-${this.currentSlide * cardWidth}%)`;
  }

  getCardWidth(): string {
    return `${100 / this.slidesToShow}%`;
  }

  getDots(): number[] {
    const maxSlide = this.getMaxSlide();
    return Array.from({ length: maxSlide + 1 }, (_, i) => i);
  }
}
