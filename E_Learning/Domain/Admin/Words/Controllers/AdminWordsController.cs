using E_Learning.Domain.Admin.Words.Dtos;
using E_Learning.Domain.Admin.Words.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace E_Learning.Domain.Admin.Words.Controllers
{
    [ApiController]
    [Route("api/admin")]
    [Authorize(Roles = "Admin")]
    public class AdminWordsController : ControllerBase
    {
        private readonly IAdminWordService _wordService;

        public AdminWordsController(IAdminWordService wordService)
        {
            _wordService = wordService;
        }

        [HttpGet("topics/{topicId:guid}/words")]
        public async Task<IActionResult> GetByTopic(Guid topicId)
        {
            try
            {
                var result = await _wordService.GetByTopicAsync(topicId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpGet("words/{wordId:guid}")]
        public async Task<IActionResult> GetById(Guid wordId)
        {
            try
            {
                var result = await _wordService.GetByIdAsync(wordId);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpPost("topics/{topicId:guid}/words")]
        public async Task<IActionResult> Create(Guid topicId, [FromBody] CreateWordRequest request)
        {
            try
            {
                var result = await _wordService.CreateAsync(topicId, request);
                return CreatedAtAction(nameof(GetById), new { wordId = result.WordId }, result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("words/{wordId:guid}")]
        public async Task<IActionResult> Update(Guid wordId, [FromBody] UpdateWordRequest request)
        {
            try
            {
                var result = await _wordService.UpdateAsync(wordId, request);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPatch("words/{wordId:guid}/toggle-active")]
        public async Task<IActionResult> ToggleActive(Guid wordId, [FromBody] ToggleWordActiveRequest request)
        {
            try
            {
                await _wordService.ToggleActiveAsync(wordId, request.IsActive);
                return Ok(new { message = "Word status updated successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpDelete("words/{wordId:guid}")]
        public async Task<IActionResult> Delete(Guid wordId)
        {
            try
            {
                await _wordService.DeleteAsync(wordId);
                return Ok(new { message = "Word deleted successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
