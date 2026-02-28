using System.ComponentModel.DataAnnotations;

namespace Domain.Entities
{
    public class Event
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(200)]
        public string Title { get; set; }

        public DateTime EventDate { get; set; }

        [MaxLength(200)]
        public string Location { get; set; } 

        public string ImageUrl { get; set; }

        public string Description { get; set; }

        public bool IsNews { get; set; }

        public Club Club { get; set; }
    }
}
